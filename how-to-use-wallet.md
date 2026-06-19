# 💼 How to Use the Block Zero Wallet

The **Block Zero wallet** is the official GUI app to hold, send, and receive **BLOZ**. It is built into [blockzero-core](https://github.com/Rexemre/blockzero-core) (`bitcoin-qt`, branded **Block Zero**).

**Next step after setup:** [How to Mine BLOZ](how-to-mine.md)

| | |
|---|---|
| **Download** | https://github.com/Rexemre/blockzero-core/releases/latest |
| **Explorer** | https://explorer.bloz.org |
| **Mainnet seed** | `217.160.46.61:8210` |
| **Mine after setup** | [How to Mine BLOZ](how-to-mine.md) |

> **Important:** Block Zero addresses start with **`bz1`** — not `bc1` (Bitcoin). You cannot send BLOZ to a Bitcoin address or vice versa.

---

## 1. Download & install

Always use the **[latest release](https://github.com/Rexemre/blockzero-core/releases/latest)**. Older builds (rc28 and earlier) had first-run bugs that are fixed in newer releases.

### 🪟 Windows

1. Download **`blockzero-*-windows-x64.zip`**
2. **Right-click → Extract All…** (do not run from inside the zip)
3. Open the extracted folder → double-click **`Start Block Zero.bat`** (or `bin\Block Zero.exe`)

> Running `Block Zero.exe` straight from the zip causes **`Qt6Gui.dll` / `Qt6Widgets.dll` not found** — the DLLs must sit next to the exe.

**Alternative (script install):**

```powershell
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops\scripts\mainnet
.\install-windows.ps1
& "$env:LOCALAPPDATA\BlockZero\bin\Block Zero.exe"
```

### 🍎 macOS (Apple Silicon — M1/M2/M3/M4)

**Easiest — one-line installer** (downloads wallet, fixes Gatekeeper, creates config):

```bash
curl -fsSL https://raw.githubusercontent.com/Rexemre/blockzero-ops/main/scripts/mainnet/install-macos.sh | bash
open "$HOME/Applications/Block Zero.app"
```

**Manual download:**

1. Download **`blockzero-*-macos-arm64.tar.gz`**
2. Extract → drag **`Block Zero.app`** to **Applications**
3. First launch: **Right-click → Open** (unsigned app — normal, not corruption)

If macOS says *"Block Zero is damaged and can't be opened"*:

```bash
xattr -dr com.apple.quarantine "$HOME/Applications/Block Zero.app"
```

Or re-run: `install-macos.sh --force`

> **Intel Macs:** no prebuilt GUI — build from source (`doc/build-osx.md` in blockzero-core).

### 🐧 Linux

**Headless server (recommended):** use the CLI — no GUI, no Qt, no display needed.

```bash
# Download from https://github.com/Rexemre/blockzero-core/releases/latest
# Pick blockzero-*-linux-x64.tar.gz (or linux-arm64)
tar -xzf blockzero-*-linux-x64.tar.gz
cd blockzero-*-linux-x64

mkdir -p ~/.blockzero-mainnet
cp bitcoin.conf.example ~/.blockzero-mainnet/bitcoin.conf
echo 'addnode=217.160.46.61:8210' >> ~/.blockzero-mainnet/bitcoin.conf

./bin/bitcoind -datadir=~/.blockzero-mainnet -daemon
./bin/bitcoin-cli -datadir=~/.blockzero-mainnet createwallet mywallet
./bin/bitcoin-cli -datadir=~/.blockzero-mainnet -rpcwallet=mywallet getnewaddress
# → copy the bz1q… address for mining
```

Then pool mine with XMRig — no local wallet GUI needed: [how-to-mine.md](how-to-mine.md)

**GUI wallet (`bin/block-zero`):** included in the Linux release tarball, but needs **Qt6 runtime libraries** and a **display** (not ideal on a headless server).

Ubuntu/Debian runtime deps:

```bash
sudo apt install libqt6widgets6 libqt6gui6 libqt6core6 libqt6network6 \
  libqrencode4 libgl1 libxkbcommon0
```

Then run `./bin/block-zero -datadir=~/.blockzero-mainnet` (requires `$DISPLAY`, or use X11 forwarding / a desktop).

> On a server, **CLI + XMRig** is the normal setup. The GUI is for desktop Linux with a monitor.

Full node details: [node-guide.md](node-guide.md)

---

## 2. First launch — welcome screen

On first start the wallet shows a short setup wizard.

| Choice | Who should pick it | Disk space |
|--------|-------------------|------------|
| **Use a full copy of the block chain** | You want to run a full node / solo mine | ~400 GB+ (grows over time) |
| **Limit block chain storage to … GB** (prune) | Most users — wallet + pool mining only | ~5–50 GB (your choice) |

**Recommendation for beginners:** choose **Limit block chain storage** (prune). You do not need a full chain copy to receive BLOZ or to pool mine.

The wallet then creates a default wallet and starts syncing. You can use the **Receive** tab and copy your address while sync is still in progress — incoming payments are recorded once the relevant blocks are synced.

---

## 3. Get your `bz1` address (Receive)

Your address is your account number on the network. You need it for mining payouts and for anyone sending you BLOZ.

1. Open **Block Zero**
2. Go to the **Receive** tab
3. Click **Create new receiving address** (if none shown)
4. **Copy** the address — it starts with **`bz1q…`**

Use this address on [pool.bloz.org](https://pool.bloz.org) and in mining commands. See [How to Mine BLOZ](how-to-mine.md).

**CLI alternative** (if `bitcoin-cli` is installed):

```bash
bitcoin-cli -datadir=~/.blockzero-mainnet getnewaddress
```

Windows:

```powershell
& "$env:LOCALAPPDATA\BlockZero\bin\bitcoin-cli.exe" -datadir="$env:LOCALAPPDATA\BlockZeroMainnet" getnewaddress
```

---

## 4. Send BLOZ

1. **Send** tab → paste the recipient's **`bz1…`** address
2. Enter the **amount** in BLOZ
3. Review the **fee** (higher fee = faster confirmation)
4. Click **Send**

Double-check the address — **crypto transactions cannot be reversed**.

Track outgoing payments on https://explorer.bloz.org

---

## 5. Understand your balance

| What you see | Meaning |
|--------------|---------|
| **Available** | BLOZ you can spend now |
| **Pending / unconfirmed** | Payment seen on the network, not yet buried in a block |
| **Immature** (mined coins) | Block reward not yet spendable — **100 blocks** (~17 hours) after the block was found |

Mining rewards (pool or solo) show as immature first, then become spendable after 100 confirmations.

---

## 6. Sync & peers

The status bar shows sync progress and peer count.

| Check | Where |
|-------|-------|
| Sync progress | Bottom of wallet window |
| Peer count | Bottom-right (should be **≥ 1**) |
| Block height | Compare with https://explorer.bloz.org |

**Stuck at launch day / 0 peers?** Newer releases embed the mainnet seed. If you still have 0 peers, add to `bitcoin.conf`:

```ini
addnode=217.160.46.61:8210
```

| OS | `bitcoin.conf` path |
|----|---------------------|
| Windows | `%LOCALAPPDATA%\BlockZeroMainnet\bitcoin.conf` |
| macOS (script install) | `~/.blockzero-mainnet/bitcoin.conf` |
| macOS (direct download) | `~/Library/Application Support/BlockZeroMainnet/bitcoin.conf` |
| Linux | `~/.blockzero-mainnet/bitcoin.conf` |

Restart the wallet after editing. In **Help → Debug window → Console**:

```
getconnectioncount   → should be ≥ 1
getblockcount        → should match explorer height
```

---

## 7. Backup & security

**You are your own bank.** If you lose your wallet file or passphrase, your BLOZ is gone.

### Encrypt your wallet

**Settings → Encrypt Wallet** → choose a strong passphrase. Required before backup on encrypted wallets.

### Backup

**File → Backup Wallet…** → save to a USB drive or encrypted cloud folder **outside** your PC.

Also back up the whole data directory periodically:

| OS | Wallet data folder |
|----|-------------------|
| Windows | `%LOCALAPPDATA%\BlockZeroMainnet\` |
| macOS (script) | `~/.blockzero-mainnet/` |
| macOS (direct) | `~/Library/Application Support/BlockZeroMainnet/` |
| Linux | `~/.blockzero-mainnet/` |

The `wallets/` subfolder holds your wallet files.

### Rules

- **Never** share your passphrase, `wallet.dat`, or private keys
- **Never** download wallets or "recovery tools" from DMs or random sites
- Only use official links: [official-links.md](official-links.md)
- Verify downloads from **https://github.com/Rexemre/blockzero-core/releases**

---

## 8. Where files live (reference)

| Item | Windows | macOS / Linux |
|------|---------|---------------|
| GUI app | `%LOCALAPPDATA%\BlockZero\bin\Block Zero.exe` | `~/Applications/Block Zero.app` |
| Config | `%LOCALAPPDATA%\BlockZeroMainnet\bitcoin.conf` | `~/.blockzero-mainnet/bitcoin.conf` |
| Wallet files | `%LOCALAPPDATA%\BlockZeroMainnet\wallets\` | `~/.blockzero-mainnet/wallets/` |
| CLI tools | `%LOCALAPPDATA%\BlockZero\bin\` | `~/.blockzero/bin/` |

Scripts from [blockzero-ops](https://github.com/Rexemre/blockzero-ops) may also create `%LOCALAPPDATA%\BlockZeroMainnet\mining-address.txt` (Windows) or `~/.blockzero-mainnet/mining-address.txt` with your payout address.

---

## 9. Troubleshooting

Common first-run issues are covered in **[FAQ → Troubleshooting](faq.md#troubleshooting-install--first-run)**:

- macOS *"Block Zero is damaged"*
- Windows `Qt6Gui.dll` / `Qt6Widgets.dll` not found
- `Prune mode is incompatible with -txindex`
- macOS `filesystem error: in equivalent`
- Sync stuck / 0 peers

Still stuck? **[Join Discord](https://discord.gg/FbJzrwAU2W)**

---

## 10. Next step — mine BLOZ

Once you have your **`bz1`** address:

→ **[How to Mine BLOZ](how-to-mine.md)** — pool mining (recommended) or solo, all operating systems.

Pool dashboard: https://pool.bloz.org
