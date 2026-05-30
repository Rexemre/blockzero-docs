# Block Zero Fork Change Map (Bitcoin Core)

This document defines what must change in a Bitcoin Core fork to create an independent Block Zero network without touching Bitcoin mainnet.

## Goal

- Separate network identity
- Reproducible genesis and chain parameters
- Minimal and auditable consensus delta
- Clear implementation order and risk profile
- Preserve upstream license and required copyright notices

## Change Areas

### 1) Chain identity and networking

Scope:
- network magic bytes
- default P2P/RPC ports
- seed nodes and seed policy
- chain IDs for mainnet/testnet/regtest

Risk: `High`  
Why: wrong values can cause accidental cross-network behavior or unstable peer connectivity.

### 2) Genesis and chain parameters

Scope:
- genesis block values
- subsidy schedule and money supply settings
- block interval target
- difficulty adjustment settings

Risk: `High`  
Why: consensus-critical; any mismatch can split the network.

### 3) Address and encoding prefixes

Scope:
- Base58 prefixes
- Bech32 human-readable prefix
- key/address user-facing formats

Risk: `High`  
Why: wrong prefixing can produce user loss due to misrouted funds.

### 4) Node/app branding and defaults

Scope:
- binary names
- config filename
- default datadir naming
- user-facing strings and docs

Risk: `Medium`  
Why: mostly operational, but naming errors confuse users and operators.

### 5) Build, test, and release hardening

Scope:
- CI build matrix
- deterministic build notes
- signed artifacts and checksums
- smoke tests for network separation

Risk: `Medium`  
Why: release mistakes create trust and security risk.

## File Targets (first-pass map)

The exact paths can differ by Bitcoin Core version. Start here:

- `src/kernel/chainparams*` and/or `src/chainparams*`
- `src/consensus/*`
- `src/net*`, `src/protocol*`, `src/node/*`
- `src/common/*`, `src/util/*`
- `src/qt/*`
- binary entry points and packaging metadata
- `doc/*`, `contrib/*`, service/manpage files

## Recommended Implementation Order

1. Freeze upstream Bitcoin Core baseline commit/tag.
2. Implement chain identity (magic/ports/seeds) with tests.
3. Implement and document genesis + chainparams for all networks.
4. Implement address prefixes and add negative tests.
5. Rebrand binaries/config/datadir and docs.
6. Run local devnet smoke tests.
7. Publish reproducibility docs and release checklist.
8. Verify legal notices remain intact before release.

## Minimum Validation Checklist

- Node never connects to Bitcoin mainnet peers.
- Mainnet/testnet/regtest all boot independently.
- Genesis hash is deterministic and documented.
- Address prefixes are unique and validated.
- Send/receive works on regtest and testnet.
- All chain-critical constants are in one reviewable document.
