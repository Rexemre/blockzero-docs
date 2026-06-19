# Quick Start: Mainnet Mining

**BLOCK ZERO** — CPU-mineable. Fair launch. Proof-of-work. No presale. No insiders.

Mine **BLOZ** on the live mainnet in a few commands.

**Pool (recommended):** https://pool.bloz.org · **Explorer:** https://explorer.bloz.org · **Seed:** `217.160.46.61:8210`

---

## Two steps — install vs wallet

| Step | Script | What it does |
|------|--------|--------------|
| **1. Install** | `install-windows.ps1` | Downloads `bitcoind` / `bitcoin-cli` only. **No wallet, no node, no mining.** |
| **2. Mine** | `mine-mainnet.ps1` | Starts node, creates wallet `mining`, generates `bz1` address, then mines (solo or pool). |

Pool and solo use the **same wallet** (`%LOCALAPPDATA%\BlockZeroMainnet`). You never install a seed node — the public seed is already in `bitcoin.conf`.

---

## Choose your platform

| Platform | Difficulty | Best for mining? |
|----------|------------|------------------|
| **Windows (native `.exe`)** | Easy with scripts | Yes — full RandomX speed |
| **Linux** | Moderate | Yes |
| **macOS** | Moderate | Yes |
| **WSL2 on Windows** | Hard, slow | **No** — use native Windows instead |

---

## Windows — pool mining (recommended)

Open **PowerShell** (not WSL):

```powershell
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops\scripts\mainnet
.\install-windows.ps1
.\mine-mainnet.ps1 -Pool
```

**First run:** installs binaries (if needed), starts `bitcoind` briefly, creates wallet + `bz1` payout address, downloads pool miner, connects to `pool.bloz.org`.  
**Later runs:** reuses your existing address automatically.

```powershell
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

**Node sync is not required for pool mining.** You only need the local node once to create the wallet address. Payouts go to your BlockZero wallet.

More detail: [blockzero-ops pool quickstart](https://github.com/Rexemre/blockzero-ops/blob/main/runbooks/pool-mining-quickstart.md)

---

## Windows — solo mining

Same install, then sync before you mine:

```powershell
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops\scripts\mainnet
.\install-windows.ps1
.\mine-mainnet.ps1 -Status    # wait until Peers >= 1
.\mine-mainnet.ps1            # solo mine
```

**Mining without peers creates a solo fork.** `-Status` must show `Peers: 1` or more and the correct genesis hash before you run solo mining.

Genesis hash ([mainnet.json](https://github.com/Rexemre/blockzero-core/blob/main/artifacts/genesis/mainnet.json)):

`44c1a8c852b3eda21966e1ddb6b0807e22488dffe8a270bf24bf1fa2d66c13bd`

If you previously mined alone with 0 peers, reset first:

```powershell
.\mine-mainnet.ps1 -Stop
.\resync-mainnet.ps1
.\mine-mainnet.ps1 -Status
```

Limit CPU (optional, **v1.0.0-rc3+** binaries):

```powershell
.\mine-mainnet.ps1 -Threads 8
.\mine-mainnet.ps1 -Stop
```

> Mainnet data lives in `%LOCALAPPDATA%\BlockZeroMainnet` — separate from testnet.

**Do not mine in WSL2** — RandomX is ~10× slower there.

---

## Pool vs solo

| | Pool (`-Pool`) | Solo |
|--|----------------|------|
| Command | `.\mine-mainnet.ps1 -Pool` | `.\mine-mainnet.ps1` |
| Wallet | BlockZero (`mining`) | Same wallet |
| Full node sync | Not needed to mine | **Required** (Peers ≥ 1) |
| Mining | Pool stratum | Local `generatetoaddress` |
| Payout | PPLNS via pool | Direct to your wallet |

---

## Wallet, node, seed — common questions

**Do I need to run a full node for pool mining?**  
No. The script starts `bitcoind` locally once to create your wallet and `bz1` address. You do not need to stay synced to mine on the pool.

**Do I need to install a seed node?**  
No. Users never run seed infrastructure. Your `bitcoin.conf` already contains `addnode=217.160.46.61:8210`.

**Where is my wallet?**  
`%LOCALAPPDATA%\BlockZeroMainnet\wallets\mining` — created by `mine-mainnet.ps1`, not by `install-windows.ps1`.

**Where is my payout address?**  
`%LOCALAPPDATA%\BlockZeroMainnet\mining-address.txt` (a `bz1...` address).

**Can I use the same wallet for pool and solo?**  
Yes. Same BlockZero wallet and address for both modes.

---

## GUI wallet (`Block Zero.exe`)

Release builds also ship a graphical node + wallet, named **`Block Zero.exe`** on Windows
and **`Block Zero.app`** on macOS. After `install-windows.ps1` it lives in
`%LOCALAPPDATA%\BlockZero\bin` and uses the mainnet datadir automatically:

```powershell
& "$env:LOCALAPPDATA\BlockZero\bin\Block Zero.exe"
```

Shows **BLOZ** balance, **Receive** tab (`bz1...`), peers and sync.

To mine from the GUI: **Window → Console** → `getnewaddress` → `generatetoaddress 1 <bz1-address>`.  
For hands-off mining, use `mine-mainnet.ps1` or `-Pool`.

---

## macOS wallet — one command (Apple Silicon)

The easiest way. This downloads the wallet, sets up the config, and makes the app
runnable so macOS does **not** show *"Block Zero is damaged and can't be opened"*:

```bash
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops/scripts/mainnet
chmod +x install-macos.sh
./install-macos.sh
open "$HOME/Applications/Block Zero.app"
```

> **If you double-clicked the download instead and macOS says *"… is damaged and can't
> be opened. You should move it to the Bin"*:** that is Gatekeeper, not a real
> corruption. Re-run `./install-macos.sh --force` (it repairs the app), or clear it
> manually: `xattr -dr com.apple.quarantine "/path/to/Block Zero.app"`.

---

## Linux / macOS

Build or download from [blockzero-core Releases](https://github.com/Rexemre/blockzero-core/releases), then:

```bash
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops/scripts/mainnet
# copy bitcoin.conf.example to ~/.blockzero-mainnet/bitcoin.conf
bitcoind -datadir=~/.blockzero-mainnet -daemon
bitcoin-cli -datadir=~/.blockzero-mainnet createwallet mining
bitcoin-cli -datadir=~/.blockzero-mainnet -rpcwallet=mining getnewaddress
```

**Pool mining (Linux x64 / macOS Apple Silicon):**

```bash
cd blockzero-ops/scripts/mainnet
chmod +x mine-pool.sh
sudo ./mine-pool.sh bz1YOURADDRESS   # sudo lets it reserve huge pages (big speedup)
# or just ./mine-pool.sh with a local wallet
```

Downloads the prebuilt miner automatically. Options: `THREADS=8 ./mine-pool.sh`, `WORKER=rig2 ./mine-pool.sh`.

> **Performance tip (important on many-core CPUs like EPYC / Threadripper):** RandomX is
> 2-3x faster with **huge pages**. Run the script once with `sudo` so it can reserve them
> (it persists across reboots). The miner prints `RandomX dataset using HUGE PAGES - full speed`
> when active; if it says *"normal 4K pages - SLOW"*, huge pages weren't reserved. Manual:
> `sudo sysctl -w vm.nr_hugepages=1280`.

See [mining-guide.md](mining-guide.md) for full details.

---

## Build from source (all platforms)

| Platform | Guide |
|----------|-------|
| Linux | [node-guide.md](node-guide.md) |
| macOS | `doc/build-osx.md` in blockzero-core |
| Windows | `doc/build-windows-msvc.md` in blockzero-core (native, not WSL) |

```powershell
.\mine-mainnet.ps1 -BinDir "C:\path\to\blockzero-core\build\bin"
```

---

## What each script does

**`install-windows.ps1`**

1. Downloads `bitcoind.exe`, `bitcoin-cli.exe` (and the GUI wallet `Block Zero.exe`) to `%LOCALAPPDATA%\BlockZero\bin`
2. Does **not** create a wallet, `bitcoin.conf`, or start mining

**`mine-mainnet.ps1`** (pool or solo)

1. Creates `%LOCALAPPDATA%\BlockZeroMainnet` and `bitcoin.conf` with the public seed
2. Starts `bitcoind` (mainnet, no `-testnet`)
3. Creates wallet `mining` and a `bz1...` mining address (`mining-address.txt`)
4. **Pool:** downloads pool miner, connects to `pool.bloz.org`
5. **Solo:** loops `generatetoaddress` (500M max tries per call, multi-threaded RandomX)

Rewards show as **BLOZ** (immature until ~100 blocks for solo coinbase).

---

## Verify sync (solo — public mainnet)

```powershell
& "$env:LOCALAPPDATA\BlockZero\bin\bitcoin-cli.exe" -datadir="$env:LOCALAPPDATA\BlockZeroMainnet" -rpcport=8332 getconnectioncount
& "$env:LOCALAPPDATA\BlockZero\bin\bitcoin-cli.exe" -datadir="$env:LOCALAPPDATA\BlockZeroMainnet" -rpcport=8332 getblockhash 0
# 44c1a8c852b3eda21966e1ddb6b0807e22488dffe8a270bf24bf1fa2d66c13bd
```

If `getconnectioncount` is **0**, do **not** solo mine — run `resync-mainnet.ps1` and ensure the seed is reachable.

---

## Block explorer

- **Mainnet:** https://explorer.bloz.org
- **Testnet:** https://texplorer.bloz.org

---

## Testnet (optional)

TBLOZ uses separate ports, addresses (`tbz1...`), and scripts:

```powershell
cd blockzero-ops\scripts\testnet
.\install-windows.ps1          # forwards to mainnet installer (same binaries)
.\mine-testnet.ps1 -Status
.\mine-testnet.ps1
```

**Testnet seed:** `217.160.46.61:18210` · **Explorer:** https://texplorer.bloz.org

See [testnet-seeds.md](testnet-seeds.md) and [testnet-reset.md](testnet-reset.md).

---

## Roadmap (easier onboarding)

| Phase | What |
|-------|------|
| **Done** | Mainnet live, pool at pool.bloz.org, one-click scripts, release binaries, GUI wallet, web explorer |
| **Next** | Signed Windows installer, Linux pool quickstart, hashrate display in miner |
| **Later** | Coin-branded explorer, mobile wallet |

See also: [mining-guide.md](mining-guide.md), [mainnet-launch.md](mainnet-launch.md)
