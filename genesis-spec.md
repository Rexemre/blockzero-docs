# Block Zero Genesis Specification (Draft v0.2)

This document defines how Block Zero genesis is selected and reproduced.

## Objectives

- Publicly verifiable genesis message
- Reproducible generation process
- No hidden allocation or hidden parameters

## Testnet v2 genesis message (2026-06-04)

Satoshi-style headline, date matches `nTime`:

```text
The Times 04/Jun/2026 Block Zero - a second chance at Genesis, fair launch, no premine
```

| Field | Value |
|-------|-------|
| `nTime` | `1780531200` (2026-06-04T00:00:00Z) |
| `nBits` | `0x1e3fffff` |

Reproduce with `blockzero-core/scripts/genesis/mine-testnet-genesis.ps1` (native Windows).

Mainnet genesis message remains unchanged until launch countdown.

## Draft Genesis Message Template (mainnet, future)

`Block Zero Genesis - Fair Launch, No ICO, No Premine - YYYY-MM-DD - <public headline/reference>`

Example (format only):

`Block Zero Genesis - Fair Launch, No ICO, No Premine - 2026-06-01 - ExampleNews: Public verifiable headline`

Requirements:
- include UTC date
- include a publicly verifiable reference
- avoid promotional or financial claims

## Fields to Publish

For each network where applicable:

- `genesis_hash`
- `merkle_root`
- `nTime`
- `nBits`
- `nonce`
- `version`
- full coinbase text

## Reproducibility Requirements

1. Commit the exact generator script/tooling.
2. Record software version and command line.
3. Record input parameters in plain text.
4. Include verification steps that reproduce the exact hash.
5. Provide at least one independent re-run by another contributor.

## Artifact Layout (recommended)

- `artifacts/genesis/mainnet.json`
- `artifacts/genesis/testnet.json`
- `artifacts/genesis/regtest.json`
- `scripts/genesis/` (generator and verifier)
- `artifacts/genesis/README.md` (how to reproduce)

## Governance Rule

- Genesis values are frozen before public launch countdown.
- Any change after freeze requires a public restart announcement.
- Genesis freeze must happen before countdown start.

## Security and Trust Notes

- Never pre-mine hidden blocks.
- Never publish private "early binary" with different params.
- Keep all genesis artifacts in the public repository.

## Delivery Checklist

- [ ] Message selected and reference archived
- [ ] Script committed
- [ ] Output values published
- [ ] Reproduction guide validated by second machine
- [ ] Launch docs linked to final genesis record
- [ ] Public proof statement confirms zero hidden allocation
