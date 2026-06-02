# Block Zero Chain Parameters v0 (Concrete Proposal)

This document proposes concrete starting values for implementation. All values are
proposals and must pass a final collision/safety review before mainnet freeze.

These values intentionally avoid known Bitcoin/Litecoin/Dogecoin network identifiers.

## 1. Emission and Supply

- Ticker: `BLOZ` (mainnet), `TBLOZ` (testnet/regtest)
- Base unit: `1 BLOZ = 100,000,000 sat` (mainnet); testnet uses `tsat` analogously
- Initial block subsidy: `50 BLOZ`
- Halving interval: `210,000 blocks`
- Target block time: `10 minutes`
- Resulting halving cadence: approximately every 4 years
- Max supply: `21,000,000 BLOZ`
- Genesis allocation: `0`
- Premine / founder reward: `0`

## 2. Network Magic Bytes (pchMessageStart)

Chosen to not overlap with common chains.

- Mainnet: `0xb1 0x0c 0x00 0xa0`
- Testnet: `0xb1 0x0c 0x74 0x45`
- Regtest: `0xb1 0x0c 0x52 0x47`

Verification rule: confirm none match Bitcoin (`f9beb4d9`), Litecoin (`fbc0b6db`),
or Dogecoin (`c0c0c0c0`) sequences before freeze.

## 3. Default Ports

Unusual ports chosen to reduce collision risk.

| Network | P2P  | RPC  |
|---------|------|------|
| Mainnet | 8210 | 8211 |
| Testnet | 18210| 18211|
| Regtest | 18212| 18213|

Verification rule: confirm ports are free of conflicts with Bitcoin defaults
(8333/8332, 18333/18332, 18444/18443) and common local services.

## 4. Address Prefixes

### Bech32 (native segwit HRP)

- Mainnet: `bz`
- Testnet: `tbz`
- Regtest: `bzrt`

### Base58 version bytes (proposal)

| Type            | Mainnet | Testnet |
|-----------------|---------|---------|
| P2PKH (pubkey)  | 25      | 65      |
| P2SH (script)   | 85      | 196     |
| WIF (secret key)| 153     | 239     |

Verification rule: generate sample addresses and confirm the resulting
leading characters are visually distinct from Bitcoin (`1`, `3`, `bc1`)
and that no encoding collisions occur. Adjust version bytes if needed.

## 5. Consensus Timing and Maturity

- Difficulty retarget interval (mainnet): `2016 blocks`
- Coinbase maturity: `100 blocks`
- Testnet: may use a more forgiving retarget to avoid stalls during low hashrate
- Regtest: deterministic, controlled mining for automation

## 6. Mining Algorithm Decision

- Decision: use RandomX (CPU-optimized, ASIC-resistant) instead of SHA-256.
- Rationale: this is the only way to make "fair mining on normal PCs" technically real.
- We use the audited reference library (tevador/RandomX, BSD-3-Clause); no custom crypto.
- See [randomx-integration.md](randomx-integration.md) for the full design.
- `powLimit` will be set to a RandomX-appropriate ceiling and calibrated on testnet.

## 7. Seeds and Bootstrapping

- No DNS seeder at first; use a small static seed list for testnet launch.
- Add DNS seeder after testnet stability is demonstrated.
- Seed node operators and addresses are tracked in the ops repository.

## 8. Open Items Before Mainnet Freeze

1. Final difficulty adjustment profile for early/low-hashrate network.
2. Confirmed non-conflicting magic bytes and ports (registry check).
3. Verified address prefix leading characters and encoding safety.
4. Final decision record on mining algorithm (baseline vs alternative).
5. Frozen genesis values linked from the genesis specification.

## Status

Draft v0. Values are implementable proposals, not final consensus constants.
Nothing here implies value, return, or investment of any kind.
