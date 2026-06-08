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

### Mainnet (live)

Mainnet addresses use the `bz1...` prefix. Launched **2026-06-06 06:06:06 UTC**
(see [mainnet-launch.md](mainnet-launch.md)).

```bash
./build/bin/bitcoind -datadir=~/.blockzero-mainnet -daemon
./build/bin/bitcoin-cli -datadir=~/.blockzero-mainnet -rpcport=8211 getblockchaininfo
```

**Public seed:** `217.160.46.61:8210` · **Explorer:** https://explorer.bloz.org

Mainnet genesis message:

```text
The Times 06/Jun/2026 Block Zero - a second chance at Genesis
```

Genesis hash: `44c1a8c852b3eda21966e1ddb6b0807e22488dffe8a270bf24bf1fa2d66c13bd`
(see [mainnet.json](https://github.com/Rexemre/blockzero-core/blob/main/artifacts/genesis/mainnet.json)).

### Testnet (optional, dev)

```bash
./build/bin/bitcoind -testnet -daemon
./build/bin/bitcoin-cli -testnet getblockchaininfo
```

Testnet addresses use the `tbz1...` prefix. **Seed:** `217.160.46.61:18210` · **Explorer:** https://texplorer.bloz.org

See [testnet-reset.md](testnet-reset.md) for genesis details.

## Network parameters (quick reference)

| Item            | Mainnet      | Testnet       | Regtest       |
|-----------------|--------------|---------------|---------------|
| P2P port        | 8210         | 18210         | 18212         |
| RPC port        | 8211         | 18211         | 18213         |
| Address prefix  | `bz`         | `tbz`         | `bzrt`        |
| Block spacing   | 10 minutes   | 10 minutes    | on demand     |
| PoW             | RandomX      | RandomX       | RandomX       |

## Connecting to peers

Public seeds are live. The scripts in `blockzero-ops` configure them automatically.
To connect manually:

```bash
# Mainnet
./build/bin/bitcoin-cli -datadir=~/.blockzero-mainnet -rpcport=8211 addnode "217.160.46.61:8210" add

# Testnet
./build/bin/bitcoin-cli -testnet addnode "217.160.46.61:18210" add
```

## Notes

- Block identity hashes are double-SHA256 (as in Bitcoin); only the proof-of-work
  check uses RandomX.
- A normal full node verifies one RandomX hash per block (a few milliseconds),
  so running a node is light on resources.
