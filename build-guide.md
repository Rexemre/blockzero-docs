# Block Zero Build Guide (MVP Draft v0.2)

This guide defines the initial build targets and release expectations.

## Supported Build Targets (MVP)

- Linux (Ubuntu LTS)
- macOS (latest stable + one previous)
- Windows (best effort in MVP, hard requirement before broad launch)

## General Build Policy

- pin dependencies where practical
- document exact toolchain versions
- publish checksums for release artifacts
- prefer reproducible build pathways
- do not publish binaries without matching source tag

## CI Expectations

- every push builds on Linux
- release-candidate branches build on Linux/macOS/Windows
- smoke tests run on regtest for each release candidate
- failed matrix blocks release tagging

## Linux (Ubuntu) - Draft Flow

1. Install required build dependencies.
2. Build from clean checkout.
3. Run basic unit/integration test set.
4. Produce and checksum artifacts.

## macOS - Draft Flow

1. Install required toolchain and deps.
2. Build binaries from clean checkout.
3. Run smoke tests (node start, regtest mine, tx send/receive).
4. Produce and checksum artifacts.

## Windows - Draft Flow

1. Prepare documented toolchain.
2. Build GUI/CLI artifacts.
3. Run startup and regtest smoke tests.
4. Publish signed or checksummed artifacts.

## Minimum Test Commands (Release Gate)

- node starts with expected datadir/config name
- node does not connect to Bitcoin mainnet
- regtest mining works
- simple transaction lifecycle works
- version/help output reflects Block Zero branding

## Troubleshooting Section (to expand)

- dependency mismatch
- linker/compiler differences
- wallet UI asset path issues
- P2P port conflicts
- wrong chainparams at runtime

## Release Checklist (short form)

- [ ] Build matrix green
- [ ] Smoke tests green
- [ ] Checksums generated
- [ ] Release notes include known limitations
- [ ] Security contact and disclosure policy linked
- [ ] Git tag matches published source state
