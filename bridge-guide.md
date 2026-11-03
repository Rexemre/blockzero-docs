# BLOZ Bridge — wBLOZ on BSC

Wrap native **BLOZ** (Block Zero mainnet) to **wBLOZ** (BEP-20 on BNB Smart Chain) for DEX trading.  
Unwrap burns wBLOZ and returns native BLOZ.

**Bridge UI:** https://bridge.bloz.org  
**Source:** [blockzero-bridge](https://github.com/Rexemre/blockzero-bridge)

---

## Live contracts (BSC mainnet)

| Contract | Address | BscScan |
|----------|---------|---------|
| wBLOZ | `0x395B11E87ac0630aF9DC32520f411dB17C13F24C` | [verified](https://bscscan.com/address/0x395B11E87ac0630aF9DC32520f411dB17C13F24C#code) |
| BlozBridge (unwrap) | `0xA7f3bEe62b20F041358062d890eF60b4E12464b7` | [verified](https://bscscan.com/address/0xA7f3bEe62b20F041358062d890eF60b4E12464b7#code) |
| BlozWrapClaim (mint) | `0x03cE8aA17Fa59E62Fd7E5af327f8b4AE47091727` | [verified](https://bscscan.com/address/0x03cE8aA17Fa59E62Fd7E5af327f8b4AE47091727#code) |

All three contracts are source-verified on BscScan. Re-verify after redeploy: `npm run verify:bsc` or `npm run verify:bridge` for BlozBridge.

---

## Trust model (read this first)

This is a **custodial bridge** with **no service fee** (0% on wrap and unwrap):

- Every **wBLOZ** in circulation should be backed **1:1** by **native BLOZ** in the bridge wallet.
- **Wrap:** you send BLOZ to a unique deposit address → after 6 confirmations you **claim** wBLOZ on BSC (you pay BNB gas). You receive **100%** of your deposit as wBLOZ. Minting is gated by the `BlozWrapClaim` contract and a relayer signature — not a manual hot-wallet mint button.
- **Unwrap:** you burn wBLOZ on `BlozBridge` → the relayer sends native BLOZ from the reserve wallet. You receive the burned amount minus a small Block Zero network fee.
- **Auto-refund:** if a deposit cannot be wrapped or is not claimed in time, BLOZ is **returned to the original sending `bz1…` address** — only the network fee is deducted.

### Verify reserves yourself

1. Open https://bridge.bloz.org — compare **Bridge reserve** and **wBLOZ supply** (should match or reserve should be higher).
2. On BscScan, read `totalSupply()` on the wBLOZ contract.
3. On https://explorer.bloz.org, check the published bridge reserve address (shown on the bridge page).

Rule: `bridge wallet BLOZ balance ≥ wBLOZ.totalSupply()`.

### Admin keys and roles (checked on-chain, 3 November 2026)

| Role | Address | Can do |
|------|---------|--------|
| `DEFAULT_ADMIN_ROLE` on wBLOZ (deployer) | `0x05099631D705210ab9B62fd696111A27446e1117` | Pause contracts, grant/revoke roles (including `MINTER_ROLE`) |
| Claim signer | same address | Signs wrap claims off-chain only |
| `MINTER_ROLE` on wBLOZ | `BlozWrapClaim` `0x03cE8aA17Fa59E62Fd7E5af327f8b4AE47091727` | Mints wBLOZ after a valid claim; the only holder of the role |

The deployer does **not** hold `MINTER_ROLE` itself. But it is the admin of the wBLOZ contract, so it **can grant itself** the
minter role at any time. It is one key, no multisig, no timelock. It did this exactly twice, for the two refunds listed below
(grant role, mint, renounce role, all visible on BscScan). Because of this, the honest guarantee is not "nobody can mint" but:
the team commits to mint only against BLOZ held in the reserve, and anyone can check that the reserve covers the supply.

**No third-party audit yet.** Contracts are open source and verified on BscScan, review the source before trusting large amounts.

### How minting and burning work

- **Wrap = mint.** Real BLOZ arrive at the bridge reserve wallet on the Block Zero chain. After 6 confirmations the server signs a
  one-time claim, you submit it, and `BlozWrapClaim` mints exactly that amount of wBLOZ to your address.
- **Unwrap = burn.** You burn wBLOZ on `BlozBridge`. The server then pays the same amount of BLOZ (minus the 0.00001 BLOZ network
  fee) from the reserve to the `bz1...` address you entered.
- Therefore wBLOZ cannot be minted freely: supply follows the reserve 1:1. Check it yourself with
  `https://bridge.bloz.org/api/status` (`bridgeBloz` against the wBLOZ supply, field `backed`) or `totalSupply()` on BscScan.

### Refunds of burned wBLOZ (2026)

An unwrap burns wBLOZ first and pays BLOZ afterwards. If the `bz1...` address typed into the unwrap is invalid (a typo), the BLOZ
cannot be paid. The burned amount is then re-minted to the sender, so the supply is backed 1:1 again. This happened twice, both
for 20 wBLOZ, both after a typo in the receive address:

| Date (UTC) | Re-mint transaction |
|------------|---------------------|
| 23 September 2026 (unwrap of 11 September) | [`0x3026e154...57cd`](https://bscscan.com/tx/0x3026e154f41b5b8184bc40084791e1981c4744be3e3bbb68e960febb327457cd) |
| 22 October 2026 (unwrap of 4 October) | [`0xc2b7e497...4f1c`](https://bscscan.com/tx/0xc2b7e4972112b18475ad126fee7346d501d8b8f04eeaea2d2cf8c22d1c844f1c) |

Since 22 October the relayer checks the address before the unwrap is processed, and an invalid address is queued for refund.

---

## Wrap flow

1. Connect MetaMask on BSC at https://bridge.bloz.org
2. Create a **unique deposit address** (one active address per wallet)
3. Send **exactly one** native BLOZ transaction (≥ 0.01 BLOZ) from your Block Zero wallet
4. Wait for **6 confirmations**
5. Click **Claim wBLOZ** (BNB gas) and import wBLOZ in MetaMask (8 decimals)

**You receive:** deposit × **100%** as wBLOZ (0% bridge fee).

**Deposit address expires** after 48 hours if no valid deposit arrives.

**Claim window:** 7 days after the deposit confirms. If you do not claim wBLOZ in time, BLOZ is auto-refunded to the address that sent the deposit.

---

## Unwrap flow

1. Connect MetaMask on BSC with wBLOZ
2. Enter amount and your `bz1…` receive address
3. Approve + `unwrap()` on BlozBridge (BNB gas)
4. Native BLOZ arrives after relayer processing (usually minutes)

**Payout** = burned wBLOZ − **0.00001 BLOZ** network fee (covers the native chain tx).

You also pay BNB gas for approve + unwrap on BSC.

---

## Auto-refund cases

| Situation | What happens |
|-----------|----------------|
| Deposit below minimum (0.01 BLOZ) | Refund to sender |
| Second deposit to same address | Refund to sender |
| Deposit after address expired | Refund to sender |
| Deposit to unknown/expired wrap | Refund to sender |
| Claimable but not claimed within 7 days | Refund to sender |

Refund amount = deposit − **0.00001 BLOZ** network fee.

Refunds require resolving the sender from the deposit transaction. If that fails temporarily, the relayer retries automatically.

---

## Fees summary

| Action | Fee |
|--------|-----|
| Wrap (claim wBLOZ) | BNB gas only |
| Unwrap | 0.00001 BLOZ network fee + BNB gas |
| Auto-refund | 0.00001 BLOZ network fee only |

---

## DEX (PancakeSwap)

Only add liquidity / trade using the **official wBLOZ contract** above.

---

## Support

- GitHub issues: [blockzero-bridge](https://github.com/Rexemre/blockzero-bridge)
- Security: see `SECURITY.md` in the bridge repo
