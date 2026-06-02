# Block Zero Mining Guide

Block Zero uses **RandomX**, a proof-of-work designed for general-purpose CPUs.
The goal is simple: let normal computers take part, the way the earliest Bitcoin
miners could. There are no guarantees of value or profit - mining here is for
participation, learning and securing the network.

> Block Zero is not Bitcoin. BLOZ has no guaranteed value, no promised liquidity
> and no expected return. Do not mine expecting financial gain.

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

## Mining on testnet

The node has built-in CPU mining via the `generatetoaddress` / `-generate` RPC:

```bash
./build/bin/bitcoind -testnet -daemon
./build/bin/bitcoin-cli -testnet createwallet test
./build/bin/bitcoin-cli -testnet -generate 1
```

The built-in miner is single-threaded and uses RandomX light mode. It is fine for
testing, but for real hashrate use an optimized, multi-threaded setup (below).

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
