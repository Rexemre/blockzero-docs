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

1. Download the **Block Zero wallet** for your OS from [Releases](https://github.com/Rexemre/blockzero-core/releases/latest).
2. Open it → **Receive** tab → **copy your `bz1q…` address**.

> CLI alternative: `bitcoin-cli getnewaddress`. Keep your wallet file and recovery info safe; never share private keys.

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

### Options
Add these **before** `bash` (Linux/macOS) or as `$env:` vars (Windows):

- **Threads:** `THREADS=8` — limit CPU threads (XMRig auto-picks the best count if omitted).
- **Rig name:** `WORKER=rig2` — label this machine on the dashboard.

Manual run (any OS): `xmrig -a rx/blockzero -o pool.bloz.org:3334 -u bz1qYOURADDRESS.rig -p x -t 8`

Your hashrate appears on https://pool.bloz.org after the first **accepted share** (a minute or two while the RandomX dataset builds). Enter your `bz1` address under **Your stats** to track earnings.

---

## 3. Solo mining — run your own node

Solo finds blocks rarely unless you have a lot of CPU power, and your node must be **synced with peers** — never mine with 0 peers, that creates a fork. The scripts check this for you.

### 🐧 Linux / 🍎 macOS
One command downloads the node, syncs to the public chain, then mines:

```bash
curl -fsSL https://raw.githubusercontent.com/Rexemre/blockzero-ops/main/scripts/mainnet/mine-solo.sh | THREADS=8 bash
```

### 🪟 Windows
In **PowerShell** (not WSL):

```powershell
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops\scripts\mainnet
.\install-windows.ps1
.\mine-mainnet.ps1 -Status     # wait until Peers >= 1 and fully synced
.\mine-mainnet.ps1             # start solo mining (add -Threads 8 to limit CPU)
```

> Advanced: change your fund contribution with `-devfundpercent=15` (min 10%) when starting the node.

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

**Mine with your CPU — not a warehouse.** Need help? [Join Discord](https://discord.gg/FbJzrwAU2W).
