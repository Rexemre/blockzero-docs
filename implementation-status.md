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

### Chain identity (separated from Bitcoin)
- Network magic: mainnet `b10c00a0`, testnet `b10c7445`, regtest `b10c5247`.
- P2P ports: 8210 / 18210 / 18212. RPC ports: 8211 / 18211 / 18213.
- Bech32 HRP: `bz` / `tbz` / `bzrt`. Base58 prefixes set; Bitcoin seeds cleared.

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

## Not done yet (known gaps)

### Difficulty calibration
- Difficulty adjustment is still upstream behavior. It needs calibration on a
  public testnet for low-hashrate stability (avoid stalls and swings).

### Seeds and public infrastructure
- No DNS/static seeds yet. Seed nodes, explorer and monitoring are not deployed.

## Suggested next steps (in order)

1. Calibrate difficulty adjustment for low-hashrate stability on a public testnet.
2. Stand up public testnet infrastructure: seed nodes, explorer, monitoring.
3. Add unit/functional test coverage for the RandomX PoW and seed rotation.
4. Build a CPU miner / mining guide so the community can mine the testnet.

## Build and test (WSL Ubuntu)

```
cmake -B build -DBUILD_GUI=OFF -DBUILD_TESTS=ON -DENABLE_IPC=OFF
cmake --build build -j <cores>
./build/bin/bitcoind -regtest -datadir=/tmp/bz -listen=0 -rpcport=19777 -daemon
./build/bin/bitcoin-cli -regtest -datadir=/tmp/bz -rpcport=19777 -generate 1
```
