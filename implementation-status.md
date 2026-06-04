# Block Zero Implementation Status

This is the honest, current state of the Block Zero core implementation. It is
updated as real, verified progress lands. It describes what is built, not plans.

Source: `blockzero-core` (fork of Bitcoin Core v31.0).

## Done and verified

### Fork baseline
- Forked Bitcoin Core `v31.0` (full git history preserved).
- Upstream pinned and tracked for security backports (see `blockzero-core/UPSTREAM.md`).
- Builds cleanly on Linux (WSL Ubuntu 22.04, CMake) and passes a regtest smoke test.

### RandomX proof-of-work (CPU-friendly, ASIC-resistant)
- Vendored `tevador/RandomX` v2.0 (BSD-3-Clause) as a pinned submodule (`src/randomx`).
- Wired into the CMake build (`librandomx.a` linked into the node and kernel).
- New module `src/pow_randomx.{h,cpp}`: thread-safe, light-mode VM cache keyed by
  the RandomX key; computes the PoW hash of an 80-byte header.
- `pow.cpp`: `GetBlockPoWHash()` plus a `CBlockHeader`-based `CheckProofOfWork`
  overload. Block identity hash stays double-SHA256; only PoW validity uses RandomX.
- Enforcement switched to RandomX in validation, block storage and mining.
- Reproducible genesis miner tool: `bz-genesis-miner`.
- RPC mining (`generatetoaddress` / `generateblock`) uses multi-threaded RandomX
  grinding in `GenerateBlock` (same light-mode path as the genesis miner).

### Chain identity (separated from Bitcoin)
- Network magic: mainnet `b10c00a0`, testnet `b10c7445`, regtest `b10c5247`.
- P2P ports: 8210 / 18210 / 18212. RPC ports: 8211 / 18211 / 18213.
- Bech32 HRP: `bz` / `tbz` / `bzrt`. Base58 prefixes set; Bitcoin seeds cleared.
- Mainnet ticker: `BLOZ` (100,000,000 sat per BLOZ). Testnet/regtest: `TBLOZ` / `tsat`.

### Seed key rotation (height-based, ASIC resistance)
- The RandomX seed key rotates by height (Monero scheme): epoch length + lag,
  key = a past block hash, not miner-selectable. Below the first epoch the
  deterministic bootstrap key is used.
- Per-network epoch params: mainnet/testnet 2048/64, regtest 16/2 (fast testing).
- Authoritative PoW check is height-aware in `ContextualCheckBlockHeader`;
  context-free checks validate only the nBits target range. `TestBlockValidity`
  skips the PoW check for unmined templates via an `fCheckPOW` flag.
- Verified on regtest: 26 blocks mined and accepted across an epoch boundary
  (mining and validation agree on the rotated key).

### Genesis blocks (all networks, RandomX)
- Distinct Block Zero genesis blocks mined under RandomX for mainnet, testnet and
  regtest (reproducible via the multi-threaded `bz-genesis-miner`).
- RandomX-appropriate difficulty floor: `powLimit` set to nBits `0x1f00ffff` for
  mainnet/testnet (regtest `0x207fffff`).
- Bitcoin-specific `nMinimumChainWork` and `defaultAssumeValid` zeroed for a fresh chain.
- Verified: mainnet and testnet nodes both boot on their new genesis; regtest mines
  end-to-end under RandomX.

### End-to-end (verified)
- Regtest: node starts on the Block Zero genesis, enforces RandomX PoW, mines via
  `-generate`, wallet yields `bzrt...` addresses, seed rotation works across an epoch.
- Testnet/Mainnet: nodes boot on their genesis (chain reports test/main, height 0).
- **Testnet block 1 mined** (2026-06-02): hash
  `7a28c3b91ddd8404a13a2557eb0e1f8bee664ffc7e7a0a90fb4473f762e6ec79`, nonce 40599.
  VPS seed (`217.160.46.61`) synced to height 1.

### Testnet v2 genesis reset (2026-06-04, in progress)
- v1 testnet had `nTime` 2025-05-30 while the coinbase text said 2026 — **bug**.
- v2 message (Satoshi-style): `The Times 04/Jun/2026 Block Zero - a second chance at Genesis, fair launch, no premine`
- `nTime = 1780531200` (2026-06-04 UTC). Mainnet genesis **unchanged**.
- Tooling: `scripts/genesis/mine-testnet-genesis.ps1` + `apply-testnet-genesis.ps1` (native Windows).
- See `blockzero-docs/testnet-v2-reset.md` for VPS + miner reset steps.

### Difficulty floor and genesis (v1 testnet, superseded)
- `powLimit` set to a safe floor `0x1e3fffff` and the retarget window shortened to
  12 hours (72 blocks, `nPowTargetTimespan = 12*60*60`). This keeps the difficulty
  math well within 256 bits (`powLimit * 4 * timespan` stays below 2^256) and is a
  good fit for a fair-launch CPU chain (faster response to early hashrate swings).
- Mainnet (nonce 425526) and testnet (nonce 175029) genesis re-mined under RandomX
  via the multi-threaded `bz-genesis-miner`. Both nodes boot on their genesis.
- `ChainParams_*_sanity` pass; the historical difficulty-retarget unit tests are
  decoupled via a local Bitcoin-like consensus and pass. New RandomX PoW determinism
  and seed-key rotation unit tests pass.

## RandomX performance note (environment, not a bug)
- In WSL2 the RandomX hashrate is low (~50 H/s/thread fast mode, ~135 H/s/thread
  light mode) even with JIT + huge pages, because the VM's memory access is heavily
  penalized under the WSL2/Hyper-V memory subsystem. On bare-metal Linux/Windows the
  same code reaches ~1000+ H/s/thread.
- Impact is limited: node block verification is one hash per block (~7 ms, fine
  everywhere). Only bulk mining is slow in WSL2. Real miners run bare metal or
  optimized miners. Genesis mining used light mode (faster in WSL2) at a feasible floor.

## Not done yet (known gaps)

### Difficulty calibration
- Difficulty adjustment is still upstream behavior. It needs calibration on a
  public testnet for low-hashrate stability (avoid stalls and swings).

### Seeds and public infrastructure
- Testnet seed node live on VPS `217.160.46.61:18210` (systemd, always-on).
- Local mining/dev node at `212.51.149.153:18210` (see `testnet-seeds.md`).
- DNS seeds, explorer and monitoring not deployed yet.

## Suggested next steps (in order)

1. Stand up public testnet infrastructure: seed nodes, DNS/static seeds, explorer, monitoring.
2. Calibrate the difficulty adjustment on a live testnet for low-hashrate stability.
3. Build/curate a CPU miner + mining guide so the community can mine the testnet
   (recommend bare-metal or an optimized RandomX miner for real hashrate).
4. Expand functional/unit test coverage (e.g. a regtest functional test that mines
   across a seed-rotation epoch boundary).

## Build and test (WSL Ubuntu)

```
cmake -B build -DBUILD_GUI=OFF -DBUILD_TESTS=ON -DENABLE_IPC=OFF
cmake --build build -j <cores>
./build/bin/bitcoind -regtest -datadir=/tmp/bz -listen=0 -rpcport=19777 -daemon
./build/bin/bitcoin-cli -regtest -datadir=/tmp/bz -rpcport=19777 -generate 1
```
