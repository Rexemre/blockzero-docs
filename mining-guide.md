# Block Zero Mining Guide

> **New users:** [How to Use the Wallet](how-to-use-wallet.md) → [How to Mine BLOZ](how-to-mine.md)  
> **Scripts & alternatives:** [quickstart-mining.md](quickstart-mining.md)

Technical background on RandomX mining on Block Zero — how it works, performance tuning, and manual RPC.

---

## What you need

- A **`bz1` address** ([wallet guide](how-to-use-wallet.md)) for pool mining, or a synced node for solo.
- A multi-core **CPU**. More cores, larger cache, and faster RAM help.
- Patience: difficulty adjusts to total network hashrate.

You do **not** need a GPU. RandomX is CPU-bound by design.

---

## How mining works

1. Your miner or node builds a candidate block header.
2. It tries nonces, hashing with RandomX.
3. If a hash is below the network target, the block (or share) is valid.
4. Your reward share ≈ your hashrate ÷ total network hashrate.

The RandomX key rotates with chain height (every epoch), keeping work bound to recent chain history — this is what maintains ASIC resistance over time.

---

## Pool vs solo

| | Pool | Solo |
|--|------|------|
| Setup | Miner only (XMRig recommended) | Full synced node |
| Rewards | Frequent PPLNS shares | Whole block when you find one |
| Guide | [how-to-mine.md](how-to-mine.md) | [how-to-mine.md § Solo](how-to-mine.md#3-solo-mining--run-your-own-node) |

**Public seed:** `217.160.46.61:8210` · **Explorer:** https://explorer.bloz.org

---

## Mining on regtest (practice)

```bash
./build/bin/bitcoind -regtest -daemon
./build/bin/bitcoin-cli -regtest createwallet test
ADDR=$(./build/bin/bitcoin-cli -regtest getnewaddress)
./build/bin/bitcoin-cli -regtest generatetoaddress 10 "$ADDR"
./build/bin/bitcoin-cli -regtest getbalance
```

---

## Solo mining (manual RPC)

Prefer scripts? See [how-to-mine.md](how-to-mine.md) or [quickstart-mining.md](quickstart-mining.md).

```bash
./build/bin/bitcoind -datadir=~/.blockzero-mainnet -daemon
./build/bin/bitcoin-cli -datadir=~/.blockzero-mainnet createwallet mining
ADDR=$(./build/bin/bitcoin-cli -datadir=~/.blockzero-mainnet -rpcwallet=mining getnewaddress)
./build/bin/bitcoin-cli -datadir=~/.blockzero-mainnet -rpcwallet=mining \
  generatetoaddress 1 "$ADDR" 500000000
```

Optional fourth argument: **thread count**. `0` or omitted = auto.

```bash
./build/bin/bitcoin-cli -datadir=~/.blockzero-mainnet -rpcwallet=mining \
  generatetoaddress 1 "$ADDR" 500000000 8
```

Script wrappers: `.\mine-mainnet.ps1 -Threads 8` (Windows) · `THREADS=8` with `mine-solo.sh` (Linux/macOS).

---

## Performance and huge pages

RandomX is memory-hard. For good performance:

- Run on **bare-metal** Linux, Windows, or macOS — not WSL2 (~10× slower).
- Enable **huge pages** on Linux for the ~2 GB RandomX dataset:

```bash
sudo sysctl -w vm.nr_hugepages=1280
```

- **XMRig** and the native pool miner both benefit. Run Linux installers with `sudo`.
- **Fast mode** (full ~2 GB dataset) vs **light mode** (256 MB, lower hashrate).

On many-core servers (EPYC, Threadripper), missing huge pages can cut hashrate by 2–3×. The miner should report `HUGE PAGES` when active.

---

## Mining on testnet

TBLOZ for development — see [quickstart-mining.md § Testnet](quickstart-mining.md#testnet-optional) or `mine-testnet.ps1` / `mine-testnet.sh`.

---

## Realistic expectations

- Reward share is proportional to your CPU hashrate vs the network.
- As more miners join, each participant's share shrinks — like early CPU-era Bitcoin.
- No premine, no ICO, no founder allocation. Coins are mined after genesis.

---

## Note

Mining is voluntary — participation in an open, CPU-fair proof-of-work network.
