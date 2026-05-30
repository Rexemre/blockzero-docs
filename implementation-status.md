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

### Regtest end-to-end (verified)
- Own Block Zero regtest genesis, mined under RandomX.
- Node starts on the new genesis, enforces RandomX PoW.
- Mining via `-generate` produces valid blocks under RandomX.
- Wallet yields `bzrt...` addresses.

## Not done yet (known gaps)

### Mainnet / testnet genesis and powLimit
- Current state: only regtest genesis is mined under RandomX. Mainnet/testnet
  still carry the upstream genesis asserts and have not been re-mined.
- Required: choose RandomX-appropriate `powLimit` per network, then mine and set
  mainnet/testnet genesis (feasible difficulty, since RandomX verification is slow).

### Difficulty calibration
- Difficulty adjustment is still upstream behavior. It needs calibration on a
  public testnet for low-hashrate stability (avoid stalls and swings).

### Seeds and public infrastructure
- No DNS/static seeds yet. Seed nodes, explorer and monitoring are not deployed.

## Suggested next steps (in order)

1. Decide mainnet/testnet `powLimit`; mine and set those genesis blocks.
2. Calibrate difficulty and stand up a public testnet with seed nodes + explorer.
3. Add unit/functional test coverage for the RandomX PoW and seed rotation.

## Build and test (WSL Ubuntu)

```
cmake -B build -DBUILD_GUI=OFF -DBUILD_TESTS=ON -DENABLE_IPC=OFF
cmake --build build -j <cores>
./build/bin/bitcoind -regtest -datadir=/tmp/bz -listen=0 -rpcport=19777 -daemon
./build/bin/bitcoin-cli -regtest -datadir=/tmp/bz -rpcport=19777 -generate 1
```
