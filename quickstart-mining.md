# Quick Start: Testnet Mining

Mine **TBLOZ** on the Block Zero testnet in a few commands. No ICO, no premine.

> TBLOZ has no guaranteed value. This is for participation and testing.

**Primary seed:** `217.160.46.61:18210` (always online)

---

## Choose your platform

| Platform | Difficulty | Best for mining? |
|----------|------------|------------------|
| **Windows (native `.exe`)** | Easy with installer | Yes — full RandomX speed |
| **Linux** | Easy | Yes |
| **macOS** | Easy | Yes |
| **WSL2 on Windows** | Hard, slow | **No** — use native Windows instead |

---

## Windows (recommended)

### 1. Install

Open **PowerShell** (not WSL):

```powershell
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops\scripts\testnet
.\install-windows.ps1
```

This downloads the latest release from [blockzero-core Releases](https://github.com/Rexemre/blockzero-core/releases) or shows build instructions if no release exists yet.

Add binaries to PATH:

```powershell
$env:Path += ";$env:LOCALAPPDATA\BlockZero\bin"
```

### 2. Mine

```powershell
.\mine-testnet.ps1
```

Check status:

```powershell
.\mine-testnet.ps1 -Status
```

Stop the node:

```powershell
.\mine-testnet.ps1 -Stop
```

**Do not mine in WSL2** — RandomX is ~10× slower there. Use the native Windows binaries.

---

## Linux

```bash
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops/scripts/testnet
chmod +x install-unix.sh mine-testnet.sh
./install-unix.sh
export PATH="$HOME/.local/share/blockzero/bin:$PATH"
./mine-testnet.sh
```

Status / stop:

```bash
./mine-testnet.sh status
./mine-testnet.sh stop
```

---

## macOS

Same as Linux:

```bash
git clone https://github.com/Rexemre/blockzero-ops.git
cd blockzero-ops/scripts/testnet
chmod +x install-unix.sh mine-testnet.sh
./install-unix.sh
export PATH="$HOME/.local/share/blockzero/bin:$PATH"
./mine-testnet.sh
```

On Apple Silicon, use the `macos-arm64` release. On Intel Macs, use `macos-x64`.

---

## Build from source (all platforms)

If no GitHub Release exists yet, build once:

| Platform | Guide |
|----------|-------|
| Linux | [node-guide.md](node-guide.md) |
| macOS | `doc/build-osx.md` in blockzero-core |
| Windows | `doc/build-windows-msvc.md` in blockzero-core (native, not WSL) |

Then point the scripts at your `build/bin`:

```powershell
# Windows
.\mine-testnet.ps1 -BinDir "C:\path\to\blockzero-core\build\bin"
```

```bash
# Linux / macOS
BZERO_BINDIR=~/blockzero-core/build/bin ./mine-testnet.sh
```

---

## What the scripts do

1. Create a data directory and `bitcoin.conf` with the public testnet seed
2. Start `bitcoind -testnet`
3. Create a wallet named `mining`
4. Loop `generatetoaddress` (multi-threaded RandomX in current builds)

Your mining address looks like: `tbz1...`  
Rewards show as **TBLOZ** (immature until ~100 blocks).

---

## Verify sync

```bash
bitcoin-cli -testnet -rpcport=18211 getblockchaininfo
bitcoin-cli -testnet -rpcport=18211 getconnectioncount   # should be >= 1
bitcoin-cli -testnet -rpcport=18211 getblockhash 0
# f58130b19cdf3d03b22c5a67a6509b00750b2d8975ee9d889d5b613aaae5296e
```

---

## Roadmap (easier onboarding)

| Phase | What |
|-------|------|
| **Now** | One-click scripts + GitHub Release binaries |
| **Next** | Signed Windows installer, `blockzero-miner` with hashrate display |
| **Later** | GUI wallet (`bitcoin-qt`), optional mining pool |

See also: [mining-guide.md](mining-guide.md), [testnet-seeds.md](testnet-seeds.md)
