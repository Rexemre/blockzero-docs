# Block Zero Launch Checklist (MVP v0.2)

Use this checklist for testnet launch readiness and later mainnet go/no-go.

## Critical Gate Items (must be green)

- network separation from Bitcoin mainnet
- reproducible genesis proof
- stable regtest/testnet transaction flow
- wallet send/receive testnet validation
- public disclaimer and non-investment messaging

## A) Technical Separation

- [ ] unique network magic bytes configured
- [ ] unique ports configured
- [ ] unique address prefixes configured
- [ ] no accidental Bitcoin mainnet peer connectivity

## B) Genesis and Chainparams

- [ ] final genesis values published
- [ ] genesis reproduction steps verified by second contributor
- [ ] chainparams frozen for launch candidate
- [ ] no hidden allocation and no premine confirmed

## C) Node and Mining Readiness

- [ ] node bootstraps on clean machine
- [ ] mining works on regtest and testnet
- [ ] first-block/first-tx flow validated end to end
- [ ] basic network health metrics available

## D) Wallet Readiness

- [ ] send/receive passes on testnet
- [ ] address format and prefix validation complete
- [ ] clear backup/recovery warnings in place
- [ ] download integrity checksums published

## E) Infra and Explorer

- [ ] minimum seed-node set deployed
- [ ] explorer reachable and indexing
- [ ] incident contact path documented
- [ ] fallback runbook ready

## F) Documentation and Website

- [ ] node guide published
- [ ] mining guide published
- [ ] FAQ published
- [ ] website has disclaimer and non-investment language

## G) Communication Compliance

- [ ] no "next Bitcoin" or profit language
- [ ] explicit "not Bitcoin" statement present
- [ ] no ICO/presale/founder allocation language conflicts

## H) Go/No-Go Decision

Launch only if all critical sections A-G are green.  
If any critical item is red, delay launch and publish the blocker transparently.

## Testnet vs Mainnet Rule

- Testnet can launch with known non-critical issues documented publicly.
- Mainnet requires all critical gate items green and no unresolved high-severity risk.
