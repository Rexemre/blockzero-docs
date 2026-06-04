# Block Zero Mainnet Launch - 2026-06-06 06:06:06 UTC

Mainnet launches at the genesis moment **2026-06-06 06:06:06 UTC** (`nTime 1780725966`).

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

## Mine on mainnet (after launch)

```powershell
cd blockzero-ops\scripts\mainnet
.\mine-mainnet.ps1 -Status   # sync to the seed first; Peers >= 1
.\mine-mainnet.ps1           # mine (works only once the launch moment has passed)
```

Mainnet uses a separate datadir (`%LOCALAPPDATA%\BlockZeroMainnet`) so it never
collides with a testnet node or wallet.

---

## Important: the node cannot run before launch

Bitcoin Core refuses to load a chain whose tip is **more than 2 hours in the
future** ("block which appears to be from the future"). Because the genesis is
timestamped 2026-06-06 06:06:06 UTC, the seed node **cannot be started before
roughly 2 hours prior to launch** - it will exit on startup until then.

This is part of the fair-launch gate: nobody can even run the chain early.

### Pre-staged (done now, before launch)
- VPS binary built with the mainnet genesis (`bitcoind --version` ok)
- `/opt/bzero-mainnet/bitcoin.conf` + datadir created
- `blockzero-mainnet.service` installed but **disabled** (so it does not crash-loop)
- ufw allows TCP 8210 (IONOS cloud firewall must also allow 8210)

### Launch day (2026-06-06, at or shortly before 06:06:06 UTC)

```bash
ssh root@217.160.46.61
systemctl enable --now blockzero-mainnet
sleep 20
systemctl is-active blockzero-mainnet
/opt/blockzero-core/build/bin/bitcoin-cli -datadir=/opt/bzero-mainnet getblockhash 0
# must equal 44c1a8c852b3eda21966e1ddb6b0807e22488dffe8a270bf24bf1fa2d66c13bd
```

> Open **TCP 8210** in the IONOS cloud firewall policy for server MarlonMorales,
> the same way port 18210 was opened for testnet.

---

## Go / No-Go (must all be green)

- [x] Mainnet genesis mined, published in `mainnet.json`, node boots on it (verified)
- [x] chainparams frozen (message, nTime, nonce, hashes)
- [x] VPS binary built, service + conf + firewall staged (service disabled until launch)
- [ ] Release binaries built and published for the launch tag
- [ ] On 2026-06-06: `systemctl enable --now blockzero-mainnet`, verify genesis
- [ ] IONOS cloud firewall allows TCP 8210
- [ ] Explorer pointed at mainnet (`explorer.bloz.org`; testnet at `texplorer.bloz.org`)
- [ ] Docs/website show "not Bitcoin", no investment/ICO language
- [ ] Disclaimer: no premine, no presale, no founder allocation

If any item is red, delay and publish the blocker transparently.
