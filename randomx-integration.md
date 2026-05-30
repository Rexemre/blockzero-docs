# RandomX Integration Design (Block Zero)

This document defines how Block Zero replaces SHA-256 proof-of-work with RandomX,
a CPU-optimized, ASIC-resistant PoW algorithm. The goal is genuine fair access for
normal PCs while keeping the rest of the Bitcoin Core architecture intact.

This is a consensus-critical change. It is implemented carefully, in stages, with
tests before any public launch.

## 1. Library

- Project: `tevador/RandomX` (https://github.com/tevador/RandomX)
- License: BSD-3-Clause (compatible with Bitcoin Core's MIT license)
- Version target: `v2.0` (pin exact tag/commit when vendored)
- Form: C++11 static library exposing a C API via `randomx.h`
- Integration form: git submodule under `src/randomx` (or `depends`), pinned.

We do not write custom cryptography. We use the audited reference implementation.

## 2. Scope of the Consensus Change

What changes:
- The proof-of-work check uses RandomX instead of double-SHA256.

What stays the same (intentional, to minimize risk):
- Block identity hash and Merkle root remain double-SHA256.
- Block/transaction serialization and structure are unchanged.
- The 80-byte block header layout is unchanged.

Rationale: only the PoW validity test is swapped. The block hash used for
identity/indexing stays SHA-256d so the surrounding code remains stable.

## 3. PoW Hash Definition

Define a dedicated PoW hash, separate from the identity hash:

- Identity hash: `SHA256d(serialized 80-byte header)` (unchanged).
- PoW hash: `RandomX(K, H)` where:
  - `H` = the serialized 80-byte block header (including nonce).
  - `K` = the RandomX key (see seed rotation below).
- Validity: interpret the RandomX 256-bit output as a little-endian number and
  require it to be `<= target(nBits)`, using the existing target logic.

The existing `CheckProofOfWork(hash, nBits)` path is adapted so the PoW branch
computes the RandomX hash of the header with the correct key for that block's
height, instead of comparing the SHA-256d header hash.

## 4. Seed Key Rotation (ASIC Resistance Requirement)

RandomX requires the key `K` to change over time and not be miner-selectable.
We adopt the proven Monero scheme:

- Key changes every `2048` blocks.
- A `64`-block lag is applied for propagation safety.
- Seed height:
  `seedHeight = (height - 64 - 1) AND NOT (2048 - 1)`
- The key `K` is the block hash at `seedHeight`.
- Early chain (`height <= 2048 + 64`): use the genesis block hash as the key.

This keeps the heavy dataset stable for ~2.8 days at a time, so miners and
verifiers do not rebuild it per block.

## 5. Verification vs Mining Modes

- Full node verification: RandomX light mode (cache, ~256 MiB). Fast enough to
  validate blocks; low memory footprint for normal nodes.
- Mining: RandomX fast mode (full dataset, ~2080 MiB) for high hashrate.
- A small manager maps the current key `K` to an initialized RandomX cache/VM,
  caching the most recent one or two keys to handle epoch boundaries and short
  reorgs without rebuilding repeatedly.

## 6. Components to Add

- `src/randomx` submodule (pinned RandomX source).
- A `pow_randomx` module (new) that:
  - owns RandomX flags (`randomx_get_flags`) plus JIT/HARD_AES when available,
  - allocates cache/dataset and creates VMs,
  - exposes `GetBlockPoWHash(header, key)` and key/VM lifecycle helpers,
  - is thread-safe for parallel validation.
- Hooks in the validation/PoW path to select the key by height and call the
  RandomX hash instead of SHA-256d for PoW.
- Build-system wiring (CMake) to compile and link RandomX.

## 7. Build System (Bitcoin Core 31.0 uses CMake)

- Add RandomX via CMake `add_subdirectory` or a `depends` package.
- Link the static `randomx` library into the node/mining targets.
- Provide build flags for portable fallback (interpreter) on non-JIT platforms.
- Keep Linux as the primary CI target first; macOS/Windows after Linux is green.

## 8. Genesis Under RandomX

- Genesis PoW must be produced with RandomX using the genesis-epoch key.
- The genesis miner initializes a RandomX cache from the bootstrap key and
  searches for a nonce whose RandomX output meets the genesis `nBits`.
- All genesis values are published and reproducible per the genesis spec.

## 9. Parameters (initial proposal)

- Block spacing: 10 minutes (per chainparams v0 decision).
- `powLimit`: set to a RandomX-appropriate ceiling so early CPU mining is viable
  but not trivial. Final value fixed after testnet calibration.
- Difficulty adjustment: start from upstream behavior, then calibrate on testnet
  for low-hashrate stability (avoid stalls and wild swings).

## 10. Risks and Mitigations

- Verification memory (~256 MiB cache): document node requirements; cache VMs.
- Epoch boundary / reorg handling: keep recent keys cached; test thoroughly.
- DoS via expensive verification: RandomX light-mode verify is bounded; reuse
  initialized cache across a key epoch.
- Build complexity across platforms: stage Linux first; portable interpreter
  fallback where JIT is unavailable.
- Consensus correctness: extensive regtest/unit tests before any public network.

## 11. Implementation Stages

1. Vendor RandomX as a pinned submodule and wire CMake build/link.
2. Add the `pow_randomx` module with key/VM management (light + fast modes).
3. Adapt the PoW verification path to use RandomX with height-based key.
4. Implement seed key rotation and early-chain bootstrap key.
5. Build a RandomX genesis miner; mine main/test/regtest genesis blocks.
6. Set chain identity (magic, ports, prefixes, hrp) and new genesis values.
7. Regtest/unit tests, then public testnet calibration.

## 12. Acceptance Criteria

- Node validates RandomX PoW correctly on regtest and testnet.
- Key rotation matches the defined schedule deterministically.
- Genesis blocks are reproducible and documented.
- A normal multi-core CPU can mine testnet blocks at the initial difficulty.
- No SHA-256d PoW acceptance remains on the Block Zero network.
