# Block Zero Mainnet Launch - 2026-06-06 06:06:06 UTC

**Mainnet is live.** Launched at the genesis moment **2026-06-06 06:06:06 UTC** (`nTime 1780725966`).

> **Fair-launch gate:** the genesis timestamp is the launch moment. A block's
> timestamp must be greater than the genesis time, so **block 1 cannot be mined
> before 06.06.2026 06:06:06 UTC** - nobody can get a head start.

## Genesis

```text
The Times 06/Jun/2026 Block Zero - a second chance at Genesis
```

| Field | Value |
|-------|-------|
| `nTime` | `1780725966` (2026-06-06 06:06:06 UTC) |
| `nBits` | `0x1e3fffff` |
| nonce | `632005` |
| **genesis hash** | `44c1a8c852b3eda21966e1ddb6b0807e22488dffe8a270bf24bf1fa2d66c13bd` |
| merkle root | `1de902b6ecd142366a9d81f27bc1a60457a56761b7bf6aafc1a6a33c3a49b005` |

Published values: [mainnet.json](https://github.com/Rexemre/blockzero-core/blob/main/artifacts/genesis/mainnet.json).
Verified: node boots on this genesis (`UpdateTip new best=...d66c13bd height=0 date=2026-06-06T06:06:06Z`).

## Network parameters

| Property | Value |
|---|---|
| P2P port | `8210` |
| RPC port | `8211` |
| Bech32 HRP | `bz` (addresses start `bz1...`) |
| Coin | BLOZ |
| PoW | RandomX (CPU-friendly) |
| Block spacing | 10 minutes |
| Retarget | 12 hours (72 blocks) |
| Halving | every 210,000 blocks |
| Max supply | 21,000,000 BLOZ |

Primary seed: `217.160.46.61:8210`.

---

## Reproduce / verify the genesis

```powershell
cd blockzero-core
cmake -B build --preset vs2026-static
cmake --build build --config Release --target bz-genesis-miner
.\scripts\genesis\mine-mainnet-genesis.ps1
```

The printed `hashGenesis` must equal the value in `mainnet.json`.

Verify the node boots on it:

```powershell
.\build\bin\Release\bitcoind.exe -datadir=$env:TEMP\bz-main-verify -daemon
.\build\bin\Release\bitcoin-cli.exe -datadir=$env:TEMP\bz-main-verify getblockhash 0
```

---

## Mine on mainnet

```powershell
cd blockzero-ops\scripts\mainnet
.\mine-mainnet.ps1 -Status   # sync to the seed first; Peers >= 1
.\mine-mainnet.ps1           # mine
```

Mainnet uses a separate datadir (`%LOCALAPPDATA%\BlockZeroMainnet`) so it never
collides with a testnet node or wallet.

---

## Fair-launch gate (historical)

Before launch, Bitcoin Core refused to load a chain whose tip was **more than 2 hours in the
future**. Because the genesis is timestamped 2026-06-06 06:06:06 UTC, the seed node could not
be started until roughly 2 hours prior to launch — ensuring nobody could get a head start.

### Launch completed (2026-06-06)

- VPS mainnet seed running (`blockzero-mainnet.service`, port 8210)
- Mainnet explorer live at [explorer.bloz.org](https://explorer.bloz.org)
- IONOS cloud firewall allows TCP 8210

See also: [mainnet-seed-node.md](https://github.com/Rexemre/blockzero-ops/blob/main/runbooks/mainnet-seed-node.md).

---

## Go / No-Go (must all be green)

- [x] Mainnet genesis mined, published in `mainnet.json`, node boots on it (verified)
- [x] chainparams frozen (message, nTime, nonce, hashes)
- [x] VPS binary built, service + conf + firewall staged
- [x] Release binaries built and published for the launch tag (**v1.0.0-rc3**)
- [x] On 2026-06-06: `systemctl enable --now blockzero-mainnet`, verify genesis
- [x] IONOS cloud firewall allows TCP 8210 (verified externally)
- [x] Explorer pointed at mainnet (`explorer.bloz.org`; testnet at `texplorer.bloz.org`)
- [x] Docs/website show "not Bitcoin", no investment/ICO language
- [x] Disclaimer: no premine, no presale, no founder allocation

If any item is red, delay and publish the blocker transparently.
