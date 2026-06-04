# Block Zero testnet v2 reset (2026-06-04)

The first public testnet had a **genesis timestamp bug**: the coinbase text said
`30/May/2026` but `nTime` decoded to **2025-05-30**. Testnet v2 fixes the date and
replaces the plain manifesto with a Satoshi-style headline.

**Mainnet genesis is unchanged** until launch.

---

## New genesis message

```text
The Times 04/Jun/2026 Block Zero - a second chance at Genesis, fair launch, no premine
```

| Field | Value |
|-------|-------|
| `nTime` | `1780531200` (2026-06-04 00:00:00 UTC) |
| `nBits` | `0x1e3fffff` |
| v1 genesis (deprecated) | `f58130b19cdf3d03b22c5a67a6509b00750b2d8975ee9d889d5b613aaae5296e` |

After mining, the v2 `hashGenesisBlock` is published in
[testnet-v2.json](https://github.com/Rexemre/blockzero-core/blob/main/artifacts/genesis/testnet-v2.json).

---

## Step 1 — Mine genesis (Windows PowerShell, native)

**Do not use WSL2** — RandomX is 10–20× slower there.

```powershell
git clone --recurse-submodules https://github.com/Rexemre/blockzero-core.git
cd blockzero-core

# If no release with bz-genesis-miner yet, build once:
cmake -B build --preset vs2026-static
cmake --build build --config Release --target bz-genesis-miner

.\scripts\genesis\mine-testnet-genesis.ps1
.\scripts\genesis\apply-testnet-genesis.ps1 -LogFile genesis-mine.log
```

Verify the node boots on the new genesis:

```powershell
cmake --build build --config Release --target bitcoind
.\build\bin\Release\bitcoind.exe -testnet -datadir=$env:TEMP\bz-genesis-test -daemon
.\build\bin\Release\bitcoin-cli.exe -testnet -datadir=$env:TEMP\bz-genesis-test getblockhash 0
# must match hashGenesis from genesis-mine.log
```

Commit, push, and tag a release (e.g. `v0.1.0-testnet.8`).

---

## Step 2 — Update ops repo

Edit `blockzero-ops/scripts/testnet/chain-identity.ps1`:

```powershell
$OfficialGenesis = "<hashGenesis from log>"
```

Commit and push `blockzero-ops`.

---

## Step 3 — Reset VPS seed (217.160.46.61)

```bash
ssh root@217.160.46.61
systemctl stop blockzero-testnet blockzero-explorer

# Wipe chain, keep config
rm -rf /opt/bzero-testnet/testnet3/blocks /opt/bzero-testnet/testnet3/chainstate

# Pull new binary (after release)
cd /opt/blockzero-core && git pull && cmake --build build -j$(nproc) --target bitcoind

systemctl start blockzero-testnet
/opt/blockzero-core/build/bin/bitcoin-cli -testnet -datadir=/opt/bzero-testnet getblockhash 0
# must match v2 genesis hash

systemctl restart blockzero-explorer
```

---

## Step 4 — Reset local miners (Windows)

```powershell
cd blockzero-ops\scripts\testnet
.\install-windows.ps1 -Version v0.1.0-testnet.8   # or latest after release
.\mine-testnet.ps1 -Stop
.\resync-testnet.ps1
.\mine-testnet.ps1 -Status   # Peers >= 1, genesis hash matches v2
.\mine-testnet.ps1           # mine block 1 on the public chain
```

All previous TBLOZ on v1 testnet are **invalid** on v2 — expected for a testnet reset.

---

## What changed vs v1

| | v1 | v2 |
|---|---|---|
| Coinbase text | `Block Zero 30/May/2026 fair launch...` | `The Times 04/Jun/2026 Block Zero - a second chance...` |
| Block timestamp | 2025-05-30 (bug) | 2026-06-04 |
| Block 1 hash | fixed in docs | **not fixed** — mined fresh after reset |

---

## FAQ

**Why not WSL?** WSL2 penalizes RandomX memory access. Native Windows reaches ~1000+ H/s/thread vs ~50–135 in WSL.

**Is mainnet affected?** No. Only `-testnet` chainparams change.

**Can I verify independently?** Yes — rebuild `bz-genesis-miner` and confirm `hashGenesis` matches the published JSON.
