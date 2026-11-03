# Block Zero timeline (verified dates)

All dates are in **2026**. Block Zero did not exist before 2026; the wBLOZ bridge exists only since 2026 as well. Dates below come
from the chain, the contracts on BscScan or the release pages of the public repositories.

| Date | Event |
|------|-------|
| 6 June 2026, 06:06:06 UTC | Mainnet genesis (fair launch, no premine, no ICO, no presale) |
| from block 1500 | Development Fund share of the block subsidy (see `dev-fund.md`) |
| August 2026 | Bridge relayer fixed after a log-cursor bug that had silently skipped two unwraps |
| 11 September 2026 | Unwrap of 20 wBLOZ with an invalid receive address (typo), BLOZ could not be paid |
| 23 September 2026 | The 20 wBLOZ were re-minted to the sender (refund 1), bridge monitoring every 5 minutes starts |
| 4 October 2026 | Second unwrap of 20 wBLOZ with a typo in the receive address |
| 22 October 2026 | Refund 2: 20 wBLOZ re-minted; invalid addresses are now queued for refund before payout; reserve topped up with 28 BLOZ |
| 29 October 2026 | Wallet v1.0.0-rc39: Linux GUI wallet (AppImage, x64 and ARM64) |
| 1 November 2026 | Group governance on BNB Smart Chain mainnet (governor v1) |
| 2 November 2026 | Governor v2 (votes without deposit); wBLOZ page https://bloz.org/wbloz/ |

Details on the bridge and the two refunds: `bridge-guide.md`. Governance: `governance/README.md`.
