# Block Zero Node Guide

How to build and run a Block Zero node from source. Block Zero is an independent,
Bitcoin-inspired, RandomX (CPU) proof-of-work network. It is not Bitcoin.

> Block Zero is an experimental open-source project. BLOZ has no guaranteed value,
> no promised liquidity and no expected return.

## Requirements

- Linux (Ubuntu 22.04+ recommended). Builds also work on macOS; Windows is best via WSL2.
- ~3 GB RAM to build, a few GB of disk.
- Build tools and libraries (Ubuntu):

```bash
sudo apt update
sudo apt install -y build-essential cmake pkgconf python3 \
  libevent-dev libboost-dev libsqlite3-dev git
```

## Get the source (with the RandomX submodule)

The RandomX proof-of-work library is a git submodule, so clone recursively:

```bash
git clone --recurse-submodules https://github.com/Rexemre/blockzero-core.git
cd blockzero-core
# if you already cloned without --recurse-submodules:
git submodule update --init --recursive
```

## Build

```bash
cmake -B build -DBUILD_GUI=OFF -DENABLE_IPC=OFF
cmake --build build -j"$(nproc)"
```

Binaries are produced in `build/bin/` (`bitcoind`, `bitcoin-cli`, `bitcoin-wallet`, ...).

## Run a node

### Regtest (local, instant blocks - great for testing)

```bash
./build/bin/bitcoind -regtest -daemon
./build/bin/bitcoin-cli -regtest createwallet test
./build/bin/bitcoin-cli -regtest -generate 1
./build/bin/bitcoin-cli -regtest getblockchaininfo
./build/bin/bitcoin-cli -regtest stop
```

Regtest addresses use the `bzrt1...` prefix.

### Testnet

```bash
./build/bin/bitcoind -testnet -daemon
./build/bin/bitcoin-cli -testnet getblockchaininfo
```

Testnet addresses use the `tbz1...` prefix.

Testnet genesis message (2026-06-04) — see [testnet-reset.md](testnet-reset.md):

```text
The Times 04/Jun/2026 Block Zero - a second chance at Genesis
```

Genesis hash: `7462293eec16a92c54a74362af6825688135e2955250024dcc3668ff4f55cfce`
(see [testnet.json](https://github.com/Rexemre/blockzero-core/blob/main/artifacts/genesis/testnet.json)).

### Mainnet

Mainnet addresses use the `bz1...` prefix. The mainnet genesis block hash is:

```
99b4f6f2a0821c6bdb7794403700424cc8f8c34d15cf79846fa4826134a59eba
```

## Network parameters (quick reference)

| Item            | Mainnet      | Testnet       | Regtest       |
|-----------------|--------------|---------------|---------------|
| P2P port        | 8210         | 18210         | 18212         |
| RPC port        | 8211         | 18211         | 18213         |
| Address prefix  | `bz`         | `tbz`         | `bzrt`        |
| Block spacing   | 10 minutes   | 10 minutes    | on demand     |
| PoW             | RandomX      | RandomX       | RandomX       |

## Connecting to peers

There are no DNS seeds yet. Until seed nodes are published, connect manually:

```bash
./build/bin/bitcoin-cli -testnet addnode "<host>:18210" add
```

## Notes

- Block identity hashes are double-SHA256 (as in Bitcoin); only the proof-of-work
  check uses RandomX.
- A normal full node verifies one RandomX hash per block (a few milliseconds),
  so running a node is light on resources.
