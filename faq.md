# Block Zero FAQ

## What is Block Zero?

**Modern BTC code. A second chance at Genesis.**

Block Zero is an independent proof-of-work chain — built on Bitcoin Core v31, mined with RandomX on ordinary CPUs, launched with no presale, no premine, and no insider allocation. Fair from block one.

## Is this Bitcoin / a new Bitcoin / Bitcoin 2.0?

No. Block Zero is **not** Bitcoin and is not a replacement for it. It is an
independent, experimental network inspired by the early Bitcoin era.

## Is BLOZ an investment? Will it be worth money?

No promises of any kind. BLOZ has no guaranteed value, no promised liquidity and
no expected return. Participation is voluntary and intended for technical,
educational and community purposes.

## Why RandomX instead of SHA-256?

SHA-256 mining is dominated by ASICs, so normal computers have no realistic chance.
RandomX is optimized for general-purpose CPUs and resists ASICs and GPUs, which
keeps participation open to ordinary hardware.

## Do I need a GPU like an RTX 4090?

No. RandomX is CPU-bound; a GPU gives little to no advantage. A modern multi-core
CPU is what matters.

## Was there a premine or ICO?

No. There is no premine, no ICO, no founder reward and no hidden allocation. The
genesis block carries no spendable allocation; coins are mined by the network after
launch. The genesis blocks are reproducible from the public source.

## Testnet genesis (2026-06-04)

The testnet runs on a RandomX genesis with a Satoshi-style headline. **Mainnet is separate and unchanged.**

See **[testnet-reset.md](testnet-reset.md)** for the reset procedure.

**Genesis message:**

```text
The Times 04/Jun/2026 Block Zero - a second chance at Genesis
```

Genesis parameters and reproduction steps: [blockzero-core/artifacts/genesis](https://github.com/Rexemre/blockzero-core/tree/main/artifacts/genesis).

## What are the genesis block hashes?

- Testnet: `7462293eec16a92c54a74362af6825688135e2955250024dcc3668ff4f55cfce`
- Mainnet: `44c1a8c852b3eda21966e1ddb6b0807e22488dffe8a270bf24bf1fa2d66c13bd` (launch 2026-06-06 06:06:06 UTC)

## How is the difficulty / supply set up?

- Proof-of-work: RandomX, with a height-based seed key rotation.
- Target block spacing: 10 minutes.
- Difficulty retargets roughly every 12 hours (72 blocks) for faster response to
  early hashrate changes.
- Mainnet launched 2026-06-06 06:06:06 UTC; parameters are being observed on the live network.

## How do I run a node or mine?

See the Node Guide and Mining Guide in this repository.

## Where is the code?

Everything is open source under `Rexemre/blockzero-core` (a fork of Bitcoin Core),
with the upstream baseline pinned and tracked for security updates.
