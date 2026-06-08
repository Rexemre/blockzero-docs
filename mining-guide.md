# Block Zero Mining Guide

> **New users:** start with [quickstart-mining.md](quickstart-mining.md) — one-click scripts for Windows, Linux and macOS.

Block Zero runs **RandomX** proof-of-work — designed so normal CPUs can mine, the way the earliest Bitcoin miners did. No ASIC advantage. No GPU arms race. Just hash power from hardware you already own.

Fair launch: no presale, no premine, no insiders. Coins exist because miners find blocks.

## What you need

- A working Block Zero node (see the Node Guide).
- A multi-core CPU. More cores, larger cache and faster RAM help.
- Patience: difficulty adjusts to the total network hashrate.

You do **not** need a GPU or special hardware. A high-end GPU (e.g. an RTX 4090)
gives essentially no advantage here - RandomX is CPU-bound by design. What matters
is your CPU.

## How mining works (short version)

1. Your node builds a candidate block.
2. It tries nonces, hashing the block header with RandomX.
3. If a hash is below the network target, the block is valid and broadcast.
4. Your chance of finding a block equals your share of the total network hashrate.

The RandomX key rotates with chain height (every epoch), so the work stays bound
to recent chain history and is not miner-selectable - this is what keeps it
ASIC-resistant over time.

## Mining on regtest (practice)

Regtest lets you mine instantly to learn the flow:

```bash
./build/bin/bitcoind -regtest -daemon
./build/bin/bitcoin-cli -regtest createwallet test
ADDR=$(./build/bin/bitcoin-cli -regtest getnewaddress)
./build/bin/bitcoin-cli -regtest generatetoaddress 10 "$ADDR"
./build/bin/bitcoin-cli -regtest getbalance
```

## Mining on mainnet

Use the [quickstart-mining.md](quickstart-mining.md) scripts, or manually:

```bash
./build/bin/bitcoind -datadir=~/.blockzero-mainnet -daemon
./build/bin/bitcoin-cli -datadir=~/.blockzero-mainnet -rpcport=8211 createwallet mining
ADDR=$(./build/bin/bitcoin-cli -datadir=~/.blockzero-mainnet -rpcport=8211 -rpcwallet=mining getnewaddress)
./build/bin/bitcoin-cli -datadir=~/.blockzero-mainnet -rpcport=8211 -rpcwallet=mining \
  generatetoaddress 1 "$ADDR" 500000000
```

**Public seed:** `217.160.46.61:8210` · **Explorer:** https://explorer.bloz.org

Optional fourth argument: **thread count** (`numthreads`). `0` or omitted = auto
(`min(logical cores, 16)`). Each thread uses ~256 MiB RAM (RandomX light mode).

```bash
# Use 8 CPU threads instead of the default auto cap
./build/bin/bitcoin-cli -datadir=~/.blockzero-mainnet -rpcport=8211 -rpcwallet=mining \
  generatetoaddress 1 "$ADDR" 500000000 8
```

Script wrappers (blockzero-core **v1.0.0-rc3+**):

| Platform | Limit threads | Use all cores (explicit) |
|----------|---------------|--------------------------|
| Windows  | `.\mine-mainnet.ps1 -Threads 8` | `.\mine-mainnet.ps1 -Threads 24` |
| Linux/macOS | build from source + RPC as above | same |

## Mining on testnet (optional)

The testnet (TBLOZ) remains available for development. See [quickstart-mining.md#testnet-optional](quickstart-mining.md#testnet-optional) or use `mine-testnet.ps1` / `mine-testnet.sh`.

The built-in miner uses multi-threaded RandomX (since v0.1). Run on **bare-metal**
Windows, Linux or macOS — not WSL2 (much slower).

## Performance and huge pages

RandomX is memory-hard. For good performance:

- Run on **bare-metal** Linux or Windows. Virtualized environments (e.g. WSL2)
  can be many times slower for mining due to memory virtualization overhead.
  Node verification is unaffected (one hash per block).
- Enable **huge pages** (Linux) for the ~2 GB RandomX dataset used in fast mode:

```bash
sudo sysctl -w vm.nr_hugepages=1280
```

- Use **fast mode** (full ~2 GB dataset) and as many threads as you have cores for
  real mining. Light mode (256 MB) is slower but uses far less memory.

## Realistic expectations

- Your reward share is proportional to your CPU hashrate vs the whole network.
- As more people join, each participant's share shrinks - exactly like the early
  days of CPU mining.
- There is no premine, no ICO and no founder allocation. The first coins are mined
  by the network after genesis.

## Honesty note

This guide describes how to participate, not how to make money. Electricity has a
cost; rewards are uncertain and have no guaranteed value. Mine because you want to
support and experience an open, fair-launch network.
