# 💼 How to Use the Block Zero Wallet

Step-by-step for absolute beginners: **install** the wallet, **create or open** it, **get your `bz1` address**, **send/receive BLOZ**, and **back up** safely — on **Windows, macOS, and Linux**, with or without a graphical interface (GUI).

The wallet is part of [blockzero-core](https://github.com/Rexemre/blockzero-core):
- **GUI** = `Block Zero` app (`bitcoin-qt`) — clickable window, best for most people.
- **CLI** = `bitcoind` + `bitcoin-cli` — terminal only, best for servers.

Both share the **same wallet and address**. After setup → **[How to Mine BLOZ](how-to-mine.md)**.

| | |
|---|---|
| **Download** | https://github.com/Rexemre/blockzero-core/releases/latest |
| **Explorer** | https://explorer.bloz.org |
| **Mainnet seed** | `217.160.46.61:8210` |

> ⚠️ Block Zero addresses start with **`bz1`** — **not** `bc1` (Bitcoin). BLOZ and BTC are different networks; you cannot send between them.

---

## 0. Which version do I need?

| You have… | Use | Section |
|-----------|-----|---------|
| Normal PC (Windows/Mac) with a screen | **GUI wallet** | [1A](#1a-install-the-gui-wallet) |
| Desktop Linux with a screen | **GUI wallet** | [1A](#1a-install-the-gui-wallet) |
| A server / VPS (no screen) | **CLI** (no GUI) | [1B](#1b-install-the-cli-no-gui) |
| Just want to mine, no wallet on this PC | Skip — use any `bz1` address you own → [How to Mine](how-to-mine.md) |

Beginners on a normal computer: use the **GUI**. It's the easiest.

---

## 1A. Install the GUI wallet

Always use the **[latest release](https://github.com/Rexemre/blockzero-core/releases/latest)**.

### 🪟 Windows

1. Download **`blockzero-*-windows-x64.zip`**
2. **Right-click → Extract All…** ← important, don't skip
3. Open the extracted folder → double-click **`Start Block Zero.bat`** (or `bin\Block Zero.exe`)

> If you run `Block Zero.exe` straight from inside the zip you get **`Qt6Gui.dll not found`**. Extract first — the DLLs must sit next to the exe.

### 🍎 macOS (Apple Silicon — M1/M2/M3/M4)

Easiest — one line in **Terminal** (downloads, fixes the "damaged" Gatekeeper warning, sets up config):

```bash
curl -fsSL https://raw.githubusercontent.com/Rexemre/blockzero-ops/main/scripts/mainnet/install-macos.sh | bash
open "$HOME/Applications/Block Zero.app"
```

Manual: download **`blockzero-*-macos-arm64.tar.gz`** → extract → drag **`Block Zero.app`** to **Applications** → **Right-click → Open** the first time.

If macOS says *"Block Zero is damaged"*: `xattr -dr com.apple.quarantine "$HOME/Applications/Block Zero.app"` (Gatekeeper, not real corruption).

> **Intel Macs:** build from source (`doc/build-osx.md`).

### 🐧 Linux desktop (with a screen)

1. Download **`blockzero-*-linux-x64.tar.gz`** (or `linux-arm64`)
2. Extract and install Qt6 runtime libraries:

```bash
tar -xzf blockzero-*-linux-x64.tar.gz
cd blockzero-*-linux-x64
sudo apt install -y libqt6widgets6 libqt6gui6 libqt6network6 libqrencode4 libgl1 libxkbcommon0
./bin/block-zero        # the GUI wallet (needs a desktop / $DISPLAY)
```

> No screen (server/VPS)? Use the **CLI** instead → [1B](#1b-install-the-cli-no-gui).

➡ Continue at [Section 2: Create or open a wallet](#2-create-or-open-a-wallet).

---

## 1B. Install the CLI (no GUI)

For servers/VPS with no screen. You get `bitcoind` (the node) and `bitcoin-cli` (commands). They use the **default mainnet folder automatically** — no `-datadir` needed.

### 🐧 Linux

```bash
# Pick linux-x64 or linux-arm64 from the releases page
curl -LO https://github.com/Rexemre/blockzero-core/releases/latest/download/blockzero-LATEST-linux-x64.tar.gz
# (or download in a browser: github.com/Rexemre/blockzero-core/releases/latest)
tar -xzf blockzero-*-linux-x64.tar.gz
cd blockzero-*-linux-x64
```

### 🪟 Windows (server / no GUI)

1. Download **`blockzero-*-windows-x64-cli.zip`** (the **`-cli`** one — smaller, no Qt)
2. **Extract All…**
3. Open **PowerShell** in the extracted folder. Commands below use `.\bin\bitcoind.exe` / `.\bin\bitcoin-cli.exe`.

### 🍎 macOS (Terminal only)

The `install-macos.sh` one-liner above also installs `bitcoind` / `bitcoin-cli` into `~/.blockzero/bin/`.

➡ Continue at [Section 2](#2-create-or-open-a-wallet) → CLI steps.

---

## 2. Create or open a wallet

### With the GUI

**First launch** shows a short setup wizard:

| Choice | Pick if… | Disk |
|--------|----------|------|
| **Limit block chain storage** (prune) | You just want a wallet / to pool mine — **most people** | ~5–50 GB |
| **Use a full copy of the block chain** | You want a full node / to solo mine | grows large |

**Beginners: choose "Limit block chain storage" (prune).** The wallet then auto-creates a default wallet and starts syncing.

- **Create another wallet:** *File → Create Wallet…* → name it → (optional) tick **Encrypt** → Create.
- **Open an existing wallet:** *File → Open Wallet…* → pick it from the list.
- Encrypting later: *Settings → Encrypt Wallet*.

You can copy your address (next step) even while it's still syncing.

### Without the GUI (CLI)

Start the node once (it connects via the built-in seed), then create a wallet:

```bash
# Linux / macOS
./bin/bitcoind -daemon                       # start node in background
./bin/bitcoin-cli createwallet "mywallet"    # create a wallet named "mywallet"
```

```powershell
# Windows (CLI zip)
.\bin\bitcoind.exe -daemon
.\bin\bitcoin-cli.exe createwallet "mywallet"
```

Useful commands:

| Goal | Command |
|------|---------|
| List wallets on disk | `bitcoin-cli listwalletdir` |
| Load an existing wallet | `bitcoin-cli loadwallet "mywallet"` |
| See loaded wallets | `bitcoin-cli listwallets` |
| Encrypt a wallet | `bitcoin-cli -rpcwallet="mywallet" encryptwallet "your-passphrase"` |
| Stop the node | `bitcoin-cli stop` |

> No `-datadir` or `-rpcport` needed — the tools use the default mainnet folder and port. Use `./bin/...` (Linux/macOS) or `.\bin\...exe` (Windows) from the extracted folder.

---

## 3. Get your `bz1` address

Your address is your account number — share it to receive BLOZ and use it for mining payouts.

**GUI:** **Receive** tab → **Create new receiving address** → **Copy**. It starts with **`bz1q…`**.

**CLI:**

```bash
bitcoin-cli -rpcwallet="mywallet" getnewaddress
# → bz1q...  (copy this)
```

You can make as many addresses as you like; they all belong to the same wallet.

Use this address on [pool.bloz.org](https://pool.bloz.org) and in mining commands → [How to Mine BLOZ](how-to-mine.md).

---

## 4. Send BLOZ

**GUI:** **Send** tab → paste the recipient's **`bz1…`** address → enter amount → check the fee → **Send**.

**CLI:**

```bash
bitcoin-cli -rpcwallet="mywallet" sendtoaddress "bz1qRECIPIENT..." 1.5
# (if encrypted, unlock first:)
bitcoin-cli -rpcwallet="mywallet" walletpassphrase "your-passphrase" 60
```

> ⚠️ Double-check the address. **Crypto transactions cannot be reversed.** Track it on https://explorer.bloz.org.

---

## 5. Understand your balance

| Shown as | Meaning |
|----------|---------|
| **Available** | Spendable now |
| **Pending / unconfirmed** | Seen by the network, not yet in a block |
| **Immature** (mined coins) | Block reward, spendable **100 blocks (~17 h)** after it was found |

Mining rewards always show as *immature* first, then become spendable.

---

## 6. Sync & peers

The wallet must reach the network (peers ≥ 1).

| Check | GUI | CLI |
|-------|-----|-----|
| Peers | bottom-right icon | `bitcoin-cli getconnectioncount` (≥ 1) |
| Height | status bar vs [explorer](https://explorer.bloz.org) | `bitcoin-cli getblockcount` |

**Stuck at launch day / 0 peers?** Add the seed to `bitcoin.conf` and restart:

```ini
addnode=217.160.46.61:8210
```

| OS | `bitcoin.conf` location |
|----|--------------------------|
| Windows | `%LOCALAPPDATA%\BlockZeroMainnet\bitcoin.conf` |
| macOS (script install) | `~/.blockzero-mainnet/bitcoin.conf` |
| macOS (direct download) | `~/Library/Application Support/BlockZeroMainnet/bitcoin.conf` |
| Linux | `~/.blockzero-mainnet/bitcoin.conf` |

---

## 7. Backup & restore

**You are your own bank.** Lose your wallet file or passphrase → your BLOZ is gone forever.

### Encrypt (do this first)

- **GUI:** *Settings → Encrypt Wallet* → strong passphrase.
- **CLI:** `bitcoin-cli -rpcwallet="mywallet" encryptwallet "your-passphrase"`

### Back up

- **GUI:** *File → Backup Wallet…* → save the `.dat` to a USB stick or encrypted cloud folder **off this PC**.
- **CLI:** `bitcoin-cli -rpcwallet="mywallet" backupwallet "/path/backup-mywallet.dat"`

Also copy the whole wallet folder now and then:

| OS | Wallet folder |
|----|---------------|
| Windows | `%LOCALAPPDATA%\BlockZeroMainnet\wallets\` |
| macOS (script) | `~/.blockzero-mainnet/wallets/` |
| macOS (direct) | `~/Library/Application Support/BlockZeroMainnet/wallets/` |
| Linux | `~/.blockzero-mainnet/wallets/` |

### Restore a backup

- **GUI:** *File → Open Wallet…*, or copy your backup into the `wallets/` folder and open it.
- **CLI:** put the backup file in a folder and run `bitcoin-cli restorewallet "mywallet" "/path/backup-mywallet.dat"`.

### Rules

- **Never** share your passphrase, `wallet.dat`, or private keys.
- **Never** download wallets or "recovery tools" from DMs or random sites — only [official links](official-links.md).
- Verify downloads come from **https://github.com/Rexemre/blockzero-core/releases**.

---

## 8. Where files live (reference)

| Item | Windows | macOS | Linux |
|------|---------|-------|-------|
| GUI app | `%LOCALAPPDATA%\BlockZero\bin\Block Zero.exe` | `~/Applications/Block Zero.app` | `./bin/block-zero` |
| Data dir | `%LOCALAPPDATA%\BlockZeroMainnet\` | `~/Library/Application Support/BlockZeroMainnet/` | `~/.blockzero-mainnet/` |
| Wallets | `…\BlockZeroMainnet\wallets\` | `…/BlockZeroMainnet/wallets/` | `~/.blockzero-mainnet/wallets/` |
| Config | `…\BlockZeroMainnet\bitcoin.conf` | `…/BlockZeroMainnet/bitcoin.conf` | `~/.blockzero-mainnet/bitcoin.conf` |

> The script installer on macOS uses `~/.blockzero-mainnet/` instead of the `Library` path. CLI tools omit `-datadir`, so they use the default folder automatically.

---

## 9. Troubleshooting

Full list in **[FAQ → Troubleshooting](faq.md#troubleshooting-install--first-run)**:

- macOS *"Block Zero is damaged"* → Gatekeeper, run `install-macos.sh` or `xattr` command.
- Windows `Qt6Gui.dll` not found → **extract the zip first**, run `Start Block Zero.bat`.
- `Prune mode is incompatible with -txindex` → a stale `bitcoin.conf` from an older install. **rc34+ auto-fixes it**; on older builds delete the `txindex=1` line (or the whole `bitcoin.conf`). See [FAQ](faq.md#prune-mode-is-incompatible-with--txindex).
- Linux server `libQt6Widgets.so.6` missing → use the **CLI** ([1B](#1b-install-the-cli-no-gui)), not the GUI.
- Sync stuck / 0 peers → add `addnode=217.160.46.61:8210` ([Section 6](#6-sync--peers)).

Still stuck? **[Join Discord](https://discord.gg/FbJzrwAU2W)**.

---

## 10. Next step — mine BLOZ

Once you have your **`bz1`** address:

→ **[How to Mine BLOZ](how-to-mine.md)** — pool (recommended) or solo, every OS, step by step.

Dashboard: https://pool.bloz.org
