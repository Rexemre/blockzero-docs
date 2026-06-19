# Advanced Mining & Scripts

**Start here if you're new:**

| Step | Guide |
|------|-------|
| 1. Wallet | **[How to Use the Wallet](how-to-use-wallet.md)** |
| 2. Mine | **[How to Mine BLOZ](how-to-mine.md)** |
| 3. Problems | **[FAQ → Troubleshooting](faq.md#troubleshooting-install--first-run)** |

This page covers **alternative mining methods**, **script internals**, **testnet**, and **solo sync checks** — not the default beginner path (XMRig one-liner).

**Pool:** https://pool.bloz.org · **Explorer:** https://explorer.bloz.org · **Seed:** `217.160.46.61:8210`

---

## Recommended vs alternative miners

| Method | Best for | Guide |
|--------|----------|-------|
| **XMRig one-liner** | Everyone (recommended) | [how-to-mine.md](how-to-mine.md) |
| **`mine-mainnet.ps1 -Pool`** | Windows — wallet + native miner in one | below |
| **`mine-pool.sh`** | Linux/macOS — native pool miner | below |
| **Solo (`mine-solo.sh` / `-Status` first)** | Running your own full node | [how-to-mine.md § Solo](how-to-mine.md#3-solo-mining--run-your-own-node) |

> **Do not use WSL2 for mining** — RandomX is ~10× slower. Use native Windows, Linux, or macOS.

---

## Windows — `mine-mainnet.ps1` (wallet + pool)

Creates wallet + `bz1` address automatically if you don't have the GUI wallet yet:

```powershell
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops\scripts\mainnet
.\install-windows.ps1
.\mine-mainnet.ps1 -Pool
.\mine-mainnet.ps1 -Pool -Threads 4   # limit CPU threads
.\mine-pool.bat                       # same as -Pool (double-click)
.\mine-pool-mainnet.ps1 -Status       # pool height, fee, stratum
.\mine-mainnet.ps1 -Status            # wallet balance, node peers
```

| Setting | Value |
|---------|-------|
| Dashboard | https://pool.bloz.org |
| Stratum | `wss://pool.bloz.org/stratum` |
| Worker | `bz1YOURADDRESS.pc` |
| Password | `x` |
| Payout | PPLNS, 2% fee, min 0.5 BLOZ |

Node sync is **not** required for pool mining with XMRig. With `-Pool`, the script starts `bitcoind` briefly to create the wallet.

---

## Windows — solo mining

Sync before you mine — **never mine with 0 peers** (creates a fork):

```powershell
.\install-windows.ps1
.\mine-mainnet.ps1 -Status    # wait until Peers >= 1
.\mine-mainnet.ps1            # solo mine
.\mine-mainnet.ps1 -Threads 8 # limit CPU threads
.\mine-mainnet.ps1 -Stop
```

Genesis hash: `44c1a8c852b3eda21966e1ddb6b0807e22488dffe8a270bf24bf1fa2d66c13bd`

If you previously mined alone with 0 peers:

```powershell
.\mine-mainnet.ps1 -Stop
.\resync-mainnet.ps1
.\mine-mainnet.ps1 -Status
```

---

## Linux / macOS — native pool miner

```bash
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops/scripts/mainnet
chmod +x mine-pool.sh
sudo ./mine-pool.sh bz1YOURADDRESS   # sudo = huge pages (big speedup)
```

Options: `THREADS=8 ./mine-pool.sh` · `WORKER=rig2 ./mine-pool.sh bz1…` · `FORCE=1` re-downloads the miner.

Pass **only your `bz1` address** — not `bz1…rig1`. The script builds the worker name automatically.

> **EPYC / Threadripper:** RandomX needs **huge pages** for full speed. Run with `sudo` once. See [mining-guide.md § Performance](mining-guide.md#performance-and-huge-pages).

Prefer XMRig? Use [how-to-mine.md](how-to-mine.md) instead.

---

## What each script does

| Script | What it does |
|--------|--------------|
| `install-windows.ps1` | Downloads `bitcoind`, `bitcoin-cli`, `Block Zero.exe` to `%LOCALAPPDATA%\BlockZero\bin`. **No wallet, no mining.** |
| `install-macos.sh` | Downloads `Block Zero.app` + tools, creates `~/.blockzero-mainnet/bitcoin.conf`, fixes Gatekeeper. |
| `mine-mainnet.ps1` | Creates wallet `mining`, `bz1` address, then pool or solo mines. |
| `mine-pool.sh` | Downloads native pool miner, connects to `pool.bloz.org`. |
| `mine-solo.sh` | Downloads node, syncs, solo mines via `generatetoaddress`. |

**Windows data dir:** `%LOCALAPPDATA%\BlockZeroMainnet`  
**Linux/macOS data dir:** `~/.blockzero-mainnet`

---

## Verify sync (solo)

```powershell
& "$env:LOCALAPPDATA\BlockZero\bin\bitcoin-cli.exe" -datadir="$env:LOCALAPPDATA\BlockZeroMainnet" getconnectioncount
& "$env:LOCALAPPDATA\BlockZero\bin\bitcoin-cli.exe" -datadir="$env:LOCALAPPDATA\BlockZeroMainnet" getblockhash 0
```

If `getconnectioncount` is **0**, do **not** solo mine — run `resync-mainnet.ps1`.

---

## Build from source

| Platform | Guide |
|----------|-------|
| Linux | [node-guide.md](node-guide.md) |
| macOS | `doc/build-osx.md` in blockzero-core |
| Windows | `doc/build-windows-msvc.md` in blockzero-core (native, not WSL) |

```powershell
.\mine-mainnet.ps1 -BinDir "C:\path\to\blockzero-core\build\bin"
```

---

## Testnet (optional)

TBLOZ — separate ports, addresses (`tbz1...`):

```powershell
cd blockzero-ops\scripts\testnet
.\mine-testnet.ps1 -Status
.\mine-testnet.ps1
```

**Testnet seed:** `217.160.46.61:18210` · **Explorer:** https://texplorer.bloz.org

See [testnet-seeds.md](testnet-seeds.md) · [testnet-reset.md](testnet-reset.md)

---

## More reading

- [mining-guide.md](mining-guide.md) — how RandomX mining works, performance, regtest
- [node-guide.md](node-guide.md) — run a full node
- [mainnet-launch.md](mainnet-launch.md) — launch details
- [blockzero-ops runbooks](https://github.com/Rexemre/blockzero-ops/tree/main/runbooks) — ops reference
