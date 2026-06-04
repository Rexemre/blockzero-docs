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

**Mining without peers creates a solo fork.** Connect to the network first.

The scripts already point at the always-on **VPS seed** `217.160.46.61:18210`, so
just check status — the node connects and syncs automatically:

```powershell
.\mine-testnet.ps1 -Status
```

This must show `Peers: 1` or more and the correct **genesis hash** (testnet v2).

After the [testnet v2 reset](https://github.com/Rexemre/blockzero-docs/blob/main/testnet-v2-reset.md), the genesis hash is published in
[testnet-v2.json](https://github.com/Rexemre/blockzero-core/blob/main/artifacts/genesis/testnet-v2.json).
Block 1 is **not** fixed — it is mined fresh after genesis.

```powershell
.\mine-testnet.ps1 -Status
# getblockhash 0 must match OfficialGenesis in chain-identity.ps1
```

If you previously mined alone (0 peers), reset the solo chain first:

```powershell
.\mine-testnet.ps1 -Stop
.\resync-testnet.ps1
.\mine-testnet.ps1 -Status
```

> The script is resilient to node restarts: it waits out RandomX startup/warmup
> and reloads the `mining` wallet automatically.

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

## GUI wallet (`bitcoin-qt`)

From release **v0.1.0-testnet.6** onward, the download also ships
`bitcoin-qt` — the full graphical node + wallet (same code as Bitcoin Core's
GUI). Use it if you'd rather see your balance and addresses in a window than on
the command line.

### Start the GUI

```powershell
& "$env:LOCALAPPDATA\BlockZero\bin\bitcoin-qt.exe" -testnet -datadir="$env:LOCALAPPDATA\BlockZero"
```

(Linux/macOS: run `bitcoin-qt` from the release's `bin/`, or open
`bitcoin-qt.app` on macOS.)

The GUI shows your **TBLOZ** balance, a **Receive** tab for addresses, peers and
sync status — no commands needed for everyday wallet use.

### Mine from the GUI

Bitcoin Core's GUI has no "mine" button, but it has a built-in console:

1. Menu **Window → Console** (or **Help → Debug window → Console**).
2. Get an address: `getnewaddress`
3. Mine blocks to it: `generatetoaddress 1 <your-tbz1-address>`
   (repeat, or pass a higher count). RandomX runs on your CPU.

The balance updates live in the **Overview** tab. For hands-off continuous
mining, keep using `mine-testnet.ps1` (it loops `generatetoaddress` for you);
the GUI can run alongside it to watch the wallet.

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

## Block explorer

Browse blocks, transactions and the chain tip in your browser:
**https://explorer.bloz.org** (self-hosted [btc-rpc-explorer](https://github.com/janoside/btc-rpc-explorer)
on the seed node).

---

## Roadmap (easier onboarding)

| Phase | What |
|-------|------|
| **Done** | One-click scripts, Release binaries, **GUI wallet (`bitcoin-qt`)**, web explorer |
| **Next** | Signed Windows installer, `blockzero-miner` with hashrate display |
| **Later** | Optional mining pool, coin-branded explorer |

See also: [mining-guide.md](mining-guide.md), [testnet-seeds.md](testnet-seeds.md)
