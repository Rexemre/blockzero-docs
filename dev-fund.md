# BLOZ Development & Growth Fund

From **block 1500**, every Block Zero block contributes a share of the block
subsidy to the public Development & Growth Fund. The fund pays for
infrastructure (seeds, pool, explorer, bridge), development, and growth
initiatives.

## How it works

- The fund is **deducted from the existing 50 BLOZ block subsidy** — no
  extra coins are created, total supply and emission stay exactly the same.
- Default contribution: **20%** of the subsidy (10 BLOZ per block).
- Consensus minimum: **10%**. Miners can lower their contribution to 15% or
  10% with the `-devfundpercent` option:

  ```
  bitcoind -devfundpercent=15
  ```

  Values below 10 are raised to the consensus minimum automatically.
- Transaction fees are **not** touched — they go to the miner in full.
- Fund address (P2WPKH, watchable by everyone):

  ```
  bz1qmv7lyweytwy807f6yq78zfvhh5ye5y2y0x2gfl
  ```

## Consensus rule

From block 1500, a coinbase that pays less than 10% of the subsidy to the
fund address is invalid (`bad-cb-devfund`) and will be rejected by upgraded
nodes. This is a coordinated flag-day upgrade like SegWit@413:

> **Every node and miner MUST upgrade to v1.0.0-rc11 (or later) before
> block 1500, otherwise it forks off the network.**

`getmininginfo` shows the fund status (`devfund` object: active flag,
activation height, minimum and configured percentage, fund address).
`getblocktemplate` reports the required fund output (`devfund`: script +
value) for pool software; `coinbasevalue` is the miner share after the
deduction.

## Pool miners

Nothing to do — the pool includes the fund output in the blocks it builds.
Pool shares and payouts are unaffected; the deduction comes out of the block
subsidy before payout distribution, like for solo miners.
