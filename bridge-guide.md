# BLOZ Bridge — wBLOZ on BSC

Wrap native **BLOZ** (Block Zero mainnet) to **wBLOZ** (BEP-20 on BNB Smart Chain) for DEX trading.  
Unwrap burns wBLOZ and returns native BLOZ.

**Bridge UI:** https://bridge.bloz.org  
**Source:** [blockzero-bridge](https://github.com/Rexemre/blockzero-bridge)

---

## Live contracts (BSC mainnet)

| Contract | Address |
|----------|---------|
| wBLOZ | `0x395B11E87ac0630aF9DC32520f411dB17C13F24C` |
| BlozBridge (unwrap) | `0xA7f3bEe62b20F041358062d890eF60b4E12464b7` |
| BlozWrapClaim (mint) | `0x03cE8aA17Fa59E62Fd7E5af327f8b4AE47091727` |

Verify source on [BscScan](https://bscscan.com) after running `npm run verify:bsc` (requires `BSCSCAN_API_KEY`).

---

## Trust model (read this first)

This is a **custodial 1:1 bridge**:

- Every **wBLOZ** in circulation should be backed by **native BLOZ** in the bridge wallet.
- **Wrap:** you send BLOZ to a unique deposit address → after 6 confirmations you **claim** wBLOZ on BSC (you pay BNB gas). Minting is gated by the `BlozWrapClaim` contract and a relayer signature — not a manual hot-wallet mint button.
- **Unwrap:** you burn wBLOZ on `BlozBridge` → the relayer sends native BLOZ from the reserve wallet (minus a small Block Zero network fee).
- **Auto-refund:** if a deposit cannot be wrapped or is not claimed in time, BLOZ is **returned to the original sending `bz1…` address** (minus the same network fee).

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

**No third-party audit yet.** Contracts are open source; verify on BscScan before trusting large amounts.

---

## Wrap flow

1. Connect MetaMask on BSC at https://bridge.bloz.org
2. Create a **unique deposit address** (one active address per wallet)
3. Send **exactly one** native BLOZ transaction (≥ 0.01 BLOZ) from your Block Zero wallet
4. Wait for **6 confirmations**
5. Click **Claim wBLOZ** (BNB gas) and import wBLOZ in MetaMask (8 decimals)

**Deposit address expires** after 48 hours if no valid deposit arrives.

**Claim window:** 7 days after the deposit confirms. If you do not claim wBLOZ in time, BLOZ is auto-refunded to the address that sent the deposit.

---

## Unwrap flow

1. Connect MetaMask on BSC with wBLOZ
2. Enter amount and your `bz1…` receive address
3. Approve + `unwrap()` on BlozBridge (BNB gas)
4. Native BLOZ arrives after relayer processing (usually minutes)

**Payout** = burned wBLOZ − **0.00001 BLOZ** network fee (covers the native chain tx).

**Bridge fee on BSC:** 0% — you only pay BNB gas.

---

## Auto-refund cases

| Situation | What happens |
|-----------|----------------|
| Deposit below minimum (0.01 BLOZ) | Refund to sender |
| Second deposit to same address | Refund to sender |
| Deposit after address expired | Refund to sender |
| Deposit to unknown/expired wrap | Refund to sender |
| Claimable but not claimed within 7 days | Refund to sender |

Refund amount = deposit − **0.00001 BLOZ** network fee (same as unwrap).

Refunds require resolving the sender from the deposit transaction. If that fails temporarily, the relayer retries automatically.

---

## Fees summary

| Action | Fee |
|--------|-----|
| Wrap (claim wBLOZ) | BNB gas only |
| Unwrap | BNB gas + 0.00001 BLOZ network fee on payout |
| Auto-refund | 0.00001 BLOZ network fee deducted |

---

## DEX (PancakeSwap)

Only add liquidity / trade using the **official wBLOZ contract** above. Scam copycat tokens may exist.

---

## Support

- GitHub issues: [blockzero-bridge](https://github.com/Rexemre/blockzero-bridge)
- Security: see `SECURITY.md` in the bridge repo
