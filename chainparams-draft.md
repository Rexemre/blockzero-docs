# Block Zero Chain Parameters (Draft v0.2)

This is the current MVP proposal before code-level implementation.

## Principles

- No premine
- No founder reward
- No ICO/presale allocation
- Conservative defaults where possible
- Keep consensus changes minimal and explicit

## Token and Emission

- Symbol: `BZERO`
- Max supply target: `21,000,000 BZERO`
- Genesis allocation: `0`
- Block 1 onward: normal mining reward only

## Timing Models Considered

### Option A (Bitcoin-like)

- Target block time: `10 minutes`
- Halving interval: `210,000 blocks`
- Pros: closest to Bitcoin behavior and operational expectations
- Cons: slower UX and slower confirmation cadence

### Option B (faster cadence)

- Target block time: `2.5 minutes`
- Halving interval: `840,000 blocks` (to keep similar time-based halving)
- Pros: faster user feedback and testing loops
- Cons: higher orphan/reorg pressure if networking is weak

## MVP Decision

Use **Option A (10 minutes)** for MVP testnet and initial mainnet:
- simpler operational assumptions
- easier comparability with Bitcoin behavior
- lower moving parts while fork is new

Option B is deferred until after post-launch stability review.

## Network-Specific Draft

### Mainnet (draft)

- unique magic bytes: `TBD (must not overlap Bitcoin/Litecoin/Dogecoin known sets)`
- default P2P port: `TBD (non-standard, non-overlapping)`
- default RPC port: `TBD (non-standard, non-overlapping)`
- address prefixes (Base58/Bech32): `TBD (visually distinct from Bitcoin)`
- checkpoints: none initially; add later via governance process

### Testnet (draft)

- separate magic bytes/ports from mainnet
- easier mining threshold for early testing
- faucet-compatible policy
- shorter difficulty-recovery behavior if needed for reliability
- no assumptions of value transfer; testing and education only

### Regtest (draft)

- local-only defaults
- instant/controlled mining for test automation
- no external peers by default
- deterministic CI-friendly settings

## Security Notes

- All chainparams must be reviewed as consensus-critical.
- Never reuse Bitcoin network identity constants.
- Prefix collisions must be tested before wallet release.

## Open Decisions

1. Difficulty adjustment profile for early network
2. Initial testnet mining ease and anti-stall behavior
3. Bech32 HRP and Base58 prefix set
4. Exact non-conflicting magic-bytes and port assignments

## Concrete Values

See [chainparams-v0-proposal.md](chainparams-v0-proposal.md) for concrete proposed
magic bytes, ports, address prefixes and emission constants.
