# Quick Start: Testnet Mining

**BLOCK ZERO** — CPU-mineable. Fair launch. Proof-of-work. No presale. No insiders.

Mine **TBLOZ** on the live testnet in a few commands. Your CPU. Your blocks.

**Primary seed:** `217.160.46.61:18210`

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

### 2. Sync to the public testnet (required — do not skip)

**Mining without peers creates a solo fork.** You must connect to the network first.

**Step A — start the WSL bridge** (VPS seed may be unreachable from some networks; WSL relay works via port 18210):

```powershell
wsl -e bash -lc "/home/marlon/blockzero-core/build/bin/bitcoind -testnet -datadir=/home/marlon/.bzero -daemon"
```

**Step B — reset any solo chain and sync** (only needed if you already mined alone):

```powershell
cd c:\Users\Marlon\blockzero\blockzero-ops\scripts\testnet
.\resync-testnet.ps1
```

**Step C — verify** (must show `Peers: 1` or more):

```powershell
.\mine-testnet.ps1 -Status
```

Expected public **block 1** hash:

`7a28c3b91ddd8404a13a2557eb0e1f8bee664ffc7e7a0a90fb4473f762e6ec79`

### 3. Mine

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

## Verify sync (public testnet)

```powershell
# PowerShell — datadir is BlockZero, not BlockZero\testnet3
& "$env:LOCALAPPDATA\BlockZero\bin\bitcoin-cli.exe" -testnet -datadir="$env:LOCALAPPDATA\BlockZero" getconnectioncount
& "$env:LOCALAPPDATA\BlockZero\bin\bitcoin-cli.exe" -testnet -datadir="$env:LOCALAPPDATA\BlockZero" getblockhash 0
# f58130b19cdf3d03b22c5a67a6509b00750b2d8975ee9d889d5b613aaae5296e
& "$env:LOCALAPPDATA\BlockZero\bin\bitcoin-cli.exe" -testnet -datadir="$env:LOCALAPPDATA\BlockZero" getblockhash 1
# 7a28c3b91ddd8404a13a2557eb0e1f8bee664ffc7e7a0a90fb4473f762e6ec79
```

```bash
# Linux / macOS
bitcoin-cli -testnet -datadir="$HOME/.blockzero" -rpcport=18211 getconnectioncount
bitcoin-cli -testnet -datadir="$HOME/.blockzero" -rpcport=18211 getblockhash 1
```

If `getconnectioncount` is **0**, do **not** mine — run `resync-testnet.ps1` (Windows) and ensure a seed is reachable. See [testnet-seeds.md](testnet-seeds.md).

## Solo fork?

If you mined with **0 peers**, you were on a private fork. Fix:

```powershell
.\mine-testnet.ps1 -Stop
.\resync-testnet.ps1
.\mine-testnet.ps1 -Status
```

---

## Roadmap (easier onboarding)

| Phase | What |
|-------|------|
| **Now** | One-click scripts + GitHub Release binaries |
| **Next** | Signed Windows installer, `blockzero-miner` with hashrate display |
| **Later** | GUI wallet (`bitcoin-qt`), optional mining pool |

See also: [mining-guide.md](mining-guide.md), [testnet-seeds.md](testnet-seeds.md)
