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

### Regtest end-to-end (verified)
- Own Block Zero regtest genesis, mined under RandomX.
- Node starts on the new genesis, enforces RandomX PoW.
- Mining via `-generate` produces valid blocks under RandomX.
- Wallet yields `bzrt...` addresses.

## Not done yet (known gaps)

### Seed key rotation (important for full ASIC resistance)
- Current state: a fixed bootstrap RandomX key is used for all heights.
- Required: rotate the key by height using the Monero scheme
  (`seedHeight = (height - 64 - 1) AND NOT (2048 - 1)`, key = block hash at
  seedHeight; genesis key for the early chain).
- Why it matters: a permanently fixed key weakens the long-term ASIC-resistance
  guarantee. Rotation binds the key to chain history and is not miner-selectable.
- Implementation note: the PoW validity check must become height-aware. In Bitcoin
  Core the header PoW is checked context-free in `CheckBlockHeader`. For rotation,
  the RandomX PoW check needs the seed block hash for the block's height, so it
  must be evaluated where chain context (pindexPrev/height) is available
  (e.g. contextual header checks), with the genesis key used below the first epoch.

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

1. Implement height-based seed key rotation (consensus-critical; test on regtest
   by mining past one epoch boundary).
2. Decide mainnet/testnet `powLimit`; mine and set those genesis blocks.
3. Calibrate difficulty and stand up a public testnet with seed nodes + explorer.

## Build and test (WSL Ubuntu)

```
cmake -B build -DBUILD_GUI=OFF -DBUILD_TESTS=ON -DENABLE_IPC=OFF
cmake --build build -j <cores>
./build/bin/bitcoind -regtest -datadir=/tmp/bz -listen=0 -rpcport=19777 -daemon
./build/bin/bitcoin-cli -regtest -datadir=/tmp/bz -rpcport=19777 -generate 1
```
