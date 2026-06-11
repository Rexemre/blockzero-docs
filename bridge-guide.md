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

This is a **custodial bridge** with a **3.9% service fee** per wrap and unwrap:

- Every **wBLOZ** in circulation should be backed by **native BLOZ** in the bridge wallet. The fee stays in the reserve, so wBLOZ remains over-backed.
- **Wrap:** you send BLOZ to a unique deposit address → after 6 confirmations you **claim** wBLOZ on BSC (you pay BNB gas). You receive **96.1%** of your deposit as wBLOZ (3.9% bridge fee). Minting is gated by the `BlozWrapClaim` contract and a relayer signature — not a manual hot-wallet mint button.
- **Unwrap:** you burn wBLOZ on `BlozBridge` → the relayer sends native BLOZ from the reserve wallet. You receive **96.1%** of the burned amount (3.9% bridge fee), minus a small Block Zero network fee.
- **Auto-refund:** if a deposit cannot be wrapped or is not claimed in time, BLOZ is **returned to the original sending `bz1…` address** — refunds carry **no bridge fee**, only the network fee.

### Verify reserves yourself

1. Open https://bridge.bloz.org — compare **Bridge reserve** and **wBLOZ supply** (should match or reserve should be higher).
2. On BscScan, read `totalSupply()` on the wBLOZ contract.
3. On https://explorer.bloz.org, check the published bridge reserve address (shown on the bridge page).

Rule: `bridge wallet BLOZ balance ≥ wBLOZ.totalSupply()`.

### Admin keys

| Role | Address | Can do |
|------|---------|--------|
| Deployer / admin | `0x05099631D705210ab9B62fd696111A27446e1117` | Pause contracts, grant/revoke roles |
| Claim signer | same as operator | Sign wrap claims off-chain only |
| Minter on-chain | `BlozWrapClaim` contract | Mint wBLOZ after valid claim |

The operator EOA does **not** hold `MINTER_ROLE` directly — only the claim contract can mint.

**No third-party audit yet.** Contracts are open source and verified on BscScan — review source before trusting large amounts.

---

## Wrap flow

1. Connect MetaMask on BSC at https://bridge.bloz.org
2. Create a **unique deposit address** (one active address per wallet)
3. Send **exactly one** native BLOZ transaction (≥ 0.01 BLOZ) from your Block Zero wallet
4. Wait for **6 confirmations**
5. Click **Claim wBLOZ** (BNB gas) and import wBLOZ in MetaMask (8 decimals)

**You receive:** deposit × **96.1%** as wBLOZ (3.9% bridge fee).

**Deposit address expires** after 48 hours if no valid deposit arrives.

**Claim window:** 7 days after the deposit confirms. If you do not claim wBLOZ in time, BLOZ is auto-refunded to the address that sent the deposit.

---

## Unwrap flow

1. Connect MetaMask on BSC with wBLOZ
2. Enter amount and your `bz1…` receive address
3. Approve + `unwrap()` on BlozBridge (BNB gas)
4. Native BLOZ arrives after relayer processing (usually minutes)

**Payout** = burned wBLOZ × **96.1%** (3.9% bridge fee) − **0.00001 BLOZ** network fee (covers the native chain tx).

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

Refund amount = deposit − **0.00001 BLOZ** network fee. Refunds carry **no 3.9% bridge fee**.

Refunds require resolving the sender from the deposit transaction. If that fails temporarily, the relayer retries automatically.

---

## Fees summary

| Action | Fee |
|--------|-----|
| Wrap (claim wBLOZ) | **3.9% bridge fee** + BNB gas |
| Unwrap | **3.9% bridge fee** + 0.00001 BLOZ network fee + BNB gas |
| Auto-refund | 0.00001 BLOZ network fee only (no bridge fee) |

---

## DEX (PancakeSwap)

Only add liquidity / trade using the **official wBLOZ contract** above. Scam copycat tokens may exist.

---

## Support

- GitHub issues: [blockzero-bridge](https://github.com/Rexemre/blockzero-bridge)
- Security: see `SECURITY.md` in the bridge repo
