# Quick Start: Mainnet Mining

**BLOCK ZERO** — CPU-mineable. Fair launch. Proof-of-work. No presale. No insiders.

Mine **BLOZ** on the live mainnet in a few commands. Your CPU. Your blocks.

**Primary seed:** `217.160.46.61:8210` · **Explorer:** https://explorer.bloz.org

---

## Choose your platform

| Platform | Difficulty | Best for mining? |
|----------|------------|------------------|
| **Windows (native `.exe`)** | Easy with installer | Yes — full RandomX speed |
| **Linux** | Moderate | Yes |
| **macOS** | Moderate | Yes |
| **WSL2 on Windows** | Hard, slow | **No** — use native Windows instead |

---

## Windows (recommended)

### 1. Install binaries

Open **PowerShell** (not WSL):

```powershell
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops\scripts\testnet
.\install-windows.ps1
```

This downloads the latest release from [blockzero-core Releases](https://github.com/Rexemre/blockzero-core/releases).

Add binaries to PATH:

```powershell
$env:Path += ";$env:LOCALAPPDATA\BlockZero\bin"
```

### 2. Sync to the public mainnet (required — do not skip)

**Mining without peers creates a solo fork.** Connect to the network first.

```powershell
cd ..\mainnet
.\mine-mainnet.ps1 -Status
```

This must show `Peers: 1` or more and the correct **genesis hash**.

The mainnet genesis hash is published in
[mainnet.json](https://github.com/Rexemre/blockzero-core/blob/main/artifacts/genesis/mainnet.json)
(`44c1a8c852b3eda21966e1ddb6b0807e22488dffe8a270bf24bf1fa2d66c13bd`).

If you previously mined alone (0 peers), reset the solo chain first:

```powershell
.\mine-mainnet.ps1 -Stop
.\resync-mainnet.ps1
.\mine-mainnet.ps1 -Status
```

> Mainnet uses a separate datadir (`%LOCALAPPDATA%\BlockZeroMainnet`) so it never
> collides with a testnet node.

### 3. Mine

```powershell
.\mine-mainnet.ps1
```

Limit CPU usage (optional, requires **v1.0.0-rc3+** binaries):

```powershell
.\mine-mainnet.ps1 -Threads 8    # ~8 cores, less heat/noise
.\mine-mainnet.ps1 -Threads 24   # use more cores on high-end CPUs
```

Check status / stop:

```powershell
.\mine-mainnet.ps1 -Status
.\mine-mainnet.ps1 -Stop
```

**Do not mine in WSL2** — RandomX is ~10× slower there. Use the native Windows binaries.

---

## GUI wallet (`bitcoin-qt`)

From release **v0.1.0-testnet.6** onward, the download also ships
`bitcoin-qt` — the full graphical node + wallet.

### Start the GUI (mainnet)

```powershell
& "$env:LOCALAPPDATA\BlockZero\bin\bitcoin-qt.exe" -datadir="$env:LOCALAPPDATA\BlockZeroMainnet"
```

The GUI shows your **BLOZ** balance, a **Receive** tab for addresses (`bz1...`), peers and
sync status.

### Mine from the GUI

1. Menu **Window → Console**.
2. Get an address: `getnewaddress`
3. Mine blocks to it: `generatetoaddress 1 <your-bz1-address>`

For hands-off continuous mining, keep using `mine-mainnet.ps1`.

---

## Linux / macOS

Build or download binaries from [blockzero-core Releases](https://github.com/Rexemre/blockzero-core/releases), then:

```bash
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops/scripts/mainnet
# copy bitcoin.conf.example to ~/.blockzero-mainnet/bitcoin.conf
bitcoind -datadir=~/.blockzero-mainnet -daemon
bitcoin-cli -datadir=~/.blockzero-mainnet -rpcport=8211 createwallet mining
bitcoin-cli -datadir=~/.blockzero-mainnet -rpcport=8211 -rpcwallet=mining generatetoaddress 1 $(bitcoin-cli -datadir=~/.blockzero-mainnet -rpcport=8211 -rpcwallet=mining getnewaddress)
```

See [mining-guide.md](mining-guide.md) for full details.

---

## Build from source (all platforms)

| Platform | Guide |
|----------|-------|
| Linux | [node-guide.md](node-guide.md) |
| macOS | `doc/build-osx.md` in blockzero-core |
| Windows | `doc/build-windows-msvc.md` in blockzero-core (native, not WSL) |

Then point the scripts at your `build/bin`:

```powershell
.\mine-mainnet.ps1 -BinDir "C:\path\to\blockzero-core\build\bin"
```

---

## What the scripts do

1. Create a mainnet data directory and `bitcoin.conf` with the public seed
2. Start `bitcoind` (no `-testnet` flag)
3. Create a wallet named `mining`
4. Loop `generatetoaddress` with 500M max tries per call (multi-threaded RandomX)

Your mining address looks like: `bz1...`  
Rewards show as **BLOZ** (immature until ~100 blocks).

---

## Verify sync (public mainnet)

```powershell
& "$env:LOCALAPPDATA\BlockZero\bin\bitcoin-cli.exe" -datadir="$env:LOCALAPPDATA\BlockZeroMainnet" getconnectioncount
& "$env:LOCALAPPDATA\BlockZero\bin\bitcoin-cli.exe" -datadir="$env:LOCALAPPDATA\BlockZeroMainnet" getblockhash 0
# 44c1a8c852b3eda21966e1ddb6b0807e22488dffe8a270bf24bf1fa2d66c13bd
```

If `getconnectioncount` is **0**, do **not** mine — run `resync-mainnet.ps1` and ensure the seed is reachable.

---

## Block explorer

- **Mainnet:** https://explorer.bloz.org
- **Testnet:** https://texplorer.bloz.org

Both are self-hosted [btc-rpc-explorer](https://github.com/janoside/btc-rpc-explorer) on the seed node.

---

## Testnet (optional)

The testnet (TBLOZ) remains live for development and testing. It uses separate ports, addresses (`tbz1...`), and scripts:

```powershell
cd blockzero-ops\scripts\testnet
.\install-windows.ps1
.\mine-testnet.ps1 -Status
.\mine-testnet.ps1
```

**Testnet seed:** `217.160.46.61:18210` · **Explorer:** https://texplorer.bloz.org

See [testnet-seeds.md](testnet-seeds.md) and [testnet-reset.md](testnet-reset.md).

---

## Roadmap (easier onboarding)

| Phase | What |
|-------|------|
| **Done** | Mainnet live, one-click scripts, Release binaries, GUI wallet (`bitcoin-qt`), web explorer |
| **Next** | Signed Windows installer, `blockzero-miner` with hashrate display |
| **Later** | Optional mining pool, coin-branded explorer |

See also: [mining-guide.md](mining-guide.md), [mainnet-launch.md](mainnet-launch.md)
