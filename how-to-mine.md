# ⛏️ How to Mine BLOZ

Block Zero (**BLOZ**) is mined with your **CPU** using RandomX on the live mainnet — no ASIC, no GPU farm needed. This guide takes you from zero to mining, step by step.

| | |
|---|---|
| **Pool** | https://pool.bloz.org |
| **Explorer** | https://explorer.bloz.org |
| **Mainnet seed** | `217.160.46.61:8210` |
| **Wallet & node** | https://github.com/Rexemre/blockzero-core/releases/latest |

---

## 1. Get your wallet address (do this first)

Mining payouts go to **your** Block Zero address (`bz1q…`). You are your own bank — the pool never holds your coins.

1. Set up a wallet → **[How to Use the Wallet](how-to-use-wallet.md)** (GUI or CLI, any OS).
2. Copy a **`bz1q…`** address: GUI **Receive** tab, or CLI `bitcoin-cli getnewaddress`.

> You don't need to keep the wallet running for **pool** mining — you just need the address. Keep your wallet backup safe; never share private keys.

---

## Pool vs Solo — which should I pick?

| | **Pool** (recommended) | **Solo** |
|---|---|---|
| Setup | A miner only | Your own full node |
| Node sync | Not required | **Required** (must be synced, peers ≥ 1) |
| Rewards | Frequent, split fairly (PPLNS), auto-paid to your address | You keep a whole block when **you** find one |
| Best for | Everyone / most CPUs | Large hashrate / running your own node |

> A share of every block automatically goes to the **Block Zero Development & Growth Fund** — default **20%** of the subsidy, consensus minimum **10%**; solo miners can change it with the node option `-devfundpercent=15`, and pool miners don't need to do anything.

---

## 2. Pool mining (recommended) — XMRig

Uses **XMRig**, the standard hardened RandomX miner. Replace `bz1qYOURADDRESS` with the address from Step 1.

### 🪟 Windows
Open **PowerShell as Administrator** (required so the installer can add a Windows Defender exclusion — antivirus flags *every* CPU miner):

```powershell
$env:ADDRESS='bz1qYOURADDRESS'; irm https://pool.bloz.org/install.ps1 | iex
```

### 🐧 Linux
Run with `sudo` so it can reserve huge pages (much higher hashrate):

```bash
curl -fsSL https://pool.bloz.org/install.sh | sudo ADDRESS=bz1qYOURADDRESS bash
```

### 🍎 macOS (Apple Silicon)

```bash
curl -fsSL https://pool.bloz.org/install.sh | ADDRESS=bz1qYOURADDRESS bash
```

### Options — threads, rig name & more

All optional except `ADDRESS`. **Leave `THREADS` unset** to let XMRig auto-pick the best count (recommended for beginners).

| Option | Windows (`$env:…`) | Linux / macOS (`VAR=value`) | Default |
|--------|-------------------|----------------------------|---------|
| **Address** | `$env:ADDRESS='bz1q…'` | `ADDRESS=bz1q…` | *(required)* |
| **Threads** | `$env:THREADS='8'` | `THREADS=8` | auto (best for your CPU) |
| **Rig name** | `$env:WORKER='gaming-pc'` | `WORKER=rig2` | your PC hostname |
| **Pool** | `$env:POOL='pool.bloz.org:3334'` | `POOL=pool.bloz.org:3334` | `pool.bloz.org:3334` |

**🪟 Windows** — PowerShell as Administrator:

```powershell
$env:ADDRESS='bz1qYOURADDRESS'; $env:THREADS='8'; $env:WORKER='gaming-pc'; irm https://pool.bloz.org/install.ps1 | iex
```

**🐧 Linux** — `sudo` reserves huge pages (much higher hashrate):

```bash
curl -fsSL https://pool.bloz.org/install.sh | sudo ADDRESS=bz1qYOURADDRESS THREADS=8 WORKER=rig2 bash
```

**🍎 macOS:**

```bash
curl -fsSL https://pool.bloz.org/install.sh | ADDRESS=bz1qYOURADDRESS THREADS=8 WORKER=mbp bash
```

**Tips**

- **Threads:** use your **physical core count** when limiting (e.g. 8-core CPU → `THREADS=8`). Omit to use all cores XMRig can efficiently run.
- **Multiple PCs:** same `ADDRESS`, different `WORKER` names — each rig shows separately on the dashboard.
- **PC in daily use:** set `THREADS` to half your cores so the machine stays responsive.

**Manual run** (after the one-liner has downloaded XMRig):

| OS | Miner location | Command |
|----|----------------|---------|
| Windows | `%LOCALAPPDATA%\BlockZero\xmrig\` | `xmrig.exe -a rx/blockzero -o pool.bloz.org:3334 -u bz1qYOURADDRESS.rig -p x -t 8 --donate-level 0` |
| Linux / macOS | `~/.blockzero/xmrig/` | `xmrig -a rx/blockzero -o pool.bloz.org:3334 -u bz1qYOURADDRESS.rig -p x -t 8 --donate-level 0` |

> Our installers set `--donate-level 0` (no donation to XMRig's developers). The Block Zero on-chain Dev & Growth Fund is separate — see [dev-fund.md](dev-fund.md).

Your hashrate appears on https://pool.bloz.org after the first **accepted share** (a minute or two while the RandomX dataset builds). Enter your `bz1` address under **Your stats** to track earnings.

---

## 3. Solo mining — run your own node

Solo finds blocks rarely unless you have a lot of CPU power, and your node must be **synced with peers** — never mine with 0 peers, that creates a fork. The scripts check this for you.

### 🐧 Linux / 🍎 macOS
One command downloads the node, syncs to the public chain, then mines:

```bash
# default threads (auto)
curl -fsSL https://raw.githubusercontent.com/Rexemre/blockzero-ops/main/scripts/mainnet/mine-solo.sh | bash

# limit CPU threads
curl -fsSL https://raw.githubusercontent.com/Rexemre/blockzero-ops/main/scripts/mainnet/mine-solo.sh | THREADS=8 bash
```

| Option | Syntax | Default |
|--------|--------|---------|
| **Threads** | `THREADS=8` | auto (all cores) |

### 🪟 Windows
In **PowerShell** (not WSL):

```powershell
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops\scripts\mainnet
.\install-windows.ps1
.\mine-mainnet.ps1 -Status          # wait until Peers >= 1 and fully synced
.\mine-mainnet.ps1                  # start solo mining (auto threads)
.\mine-mainnet.ps1 -Threads 8       # limit CPU threads
```

| Option | Syntax | Default |
|--------|--------|---------|
| **Threads** | `-Threads 8` | auto |

### Solo from the GUI wallet (any OS)

If you already run the **GUI** wallet as a full node (not prune) and it's synced with peers ≥ 1:

1. **Window → Console** (or Help → Debug window → Console)
2. Run:

```
getnewaddress
generatetoaddress 1 bz1qYOURADDRESS 100000000 8
```

`100000000` = max hashing tries per call, `8` = threads (omit for auto). Repeat or loop the `generatetoaddress` line.

> Advanced: change your fund contribution with the node option `-devfundpercent=15` (min 10%) when starting `bitcoind`. See [dev-fund.md](dev-fund.md).

---

## Monitor & control

- **Pool:** watch your `bz1` address on https://pool.bloz.org → *Your stats*.
- **Windows solo:** `.\mine-mainnet.ps1 -Status` (height, peers, hashrate) · `.\mine-mainnet.ps1 -Stop`.
- **Linux/macOS solo:** the script prints height each round; stop the node with `~/.blockzero/bin/bitcoin-cli -datadir=~/.blockzero-mainnet stop`.

---

## 🔒 Safety

- Only use official `*.bloz.org` links and the ones in [official-links.md](official-links.md).
- **Never** download miners from random users or run scripts from DMs.
- **Never** share private keys or wallet files.
- Windows antivirus flags all CPU miners as "riskware" — our installer adds the exclusion (run as Administrator). The XMRig build is fully open source: [xmrig-bz/](https://github.com/Rexemre/blockzero-ops/tree/main/xmrig-bz).

---

## Alternative methods

Native miner scripts, `mine-mainnet.ps1`, testnet, and script internals:

→ **[quickstart-mining.md](quickstart-mining.md)** (advanced)

---

**Mine with your CPU — not a warehouse.** Need help? [Join Discord](https://discord.gg/FbJzrwAU2W).
