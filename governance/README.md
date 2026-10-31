# Block Zero group governance (community groups on bloz.org)

Smart contracts that give every community group on [bloz.org/community](https://bloz.org/community) its own on-chain
treasury and on-chain votes. A payout from a group treasury happens **only** when the group's vote passes, the timelock
has run out and nothing is paused; then **anyone** may trigger it. Nobody on the site, not the founder, not the server,
not the project lead, can move money out of a treasury.

**Status (31 October 2026): test chain only, test coins only.** Mainnet will follow only after an external review.

## What the contracts enforce

| Contract | Role |
|---|---|
| `BlozGroupGovernor` | One contract for all groups. Creates a treasury per group (EIP-1167 clone), runs the votes, executes passed payments after the timelock. Roles: admin = `TimelockController`, guardian (pause, veto, lower caps), registrar (the community server: creates groups, mirrors admins as proposers). |
| `BlozGroupTreasury` | A group's treasury. Holds and pays **wBLOZ and nothing else**: the token is fixed at creation (`vault.token()`), there is no `receive`/`fallback` (a plain BNB transfer reverts), no token argument in `pay()`, no generic call, no owner, no upgrade, no rescue function. `pay()` can be called by the governor only. |
| `BlozVoterID` | Soulbound token (ERC-5192): one verified person = one token = one vote. Minted and revoked by the server; `memberSince` per wallet; a hashed person reference blocks second IDs for the same person. |
| `BlozVotingVault` | wBLOZ deposits with block checkpoints: the token weight of a vote is the deposit at the proposal's snapshot block. No admin, deposit and withdraw always open. |
| `LinearWeight` / `LogWeight` | "One BLOZ, one vote" (whole BLOZ, lower of snapshot and holding-period balance) and the logarithmic variant `log2(1 + BLOZ/10)`. |

Counting modes (chosen per vote by its creator): **people** (1 verified person = 1 vote), **linear** (1 BLOZ = 1 vote),
**logarithmic**, or a combination of people with one balance count = double majority (both must say yes; a split result is
rejected). Payments need a quorum of people, a 60 % yes share, a longer minimum voting period and a timelock; a payment
that nobody executes within the grace period expires. Members vote with a free EIP-712 signature that the server relays
(the server pays the gas, the member stays the signer); direct transactions work too.

### wBLOZ only (since 31 October 2026)

Earlier versions could also hold and pay out BNB. Now the governor knows exactly one payable asset, `WBLOZ` (immutable,
equal to the voting vault's token). A proposal that names BNB (`token = 0`) or any other token reverts with
`TokenNotAllowed`; `setMaxAmount` / `lowerMaxAmount` accept only that token; the treasury has no native-coin path at all.
BNB or foreign tokens forced into a treasury stay stuck on purpose (a rescue path would be an attack surface).

## Where it runs

Block Zero test chain (EVM, Ganache with persistent state, empty block every 5 s). Add it to MetaMask with
chain id `97097` (`0x17b49`), RPC `https://bloz.org/testchain-rpc` (read methods and signed transactions only; no
`evm_*`, no node accounts), currency `tBNB` (no value).

| | Address (test chain 97097) |
|---|---|
| Governor | `0x0aF45fe48957f55c48847F9811932ca73053aBE4` |
| Treasury implementation | `0x41b37f8Ea1fb141D017840Fd7Cd243E9fC39819E` |
| Voter ID | `0xf24eE2DaDd610e75F0fBfACFd67129f55Dcc7563` |
| Voting vault | `0xAA8915C21aFf6138ab19726cd060B5C994c42846` |
| Test wBLOZ (`TestWBLOZ`, 8 decimals, `faucet()` gives 1 000 per day) | `0x8DD757e108D7d868Ed81D81F01A0F660BC5A64CB` |
| Timelock (admin) | `0x26EA80c7F506472610f0DccFD31c9ca61422537f` |
| Deploy tx | `0x6611b54d961e347b6badfae9c53c0a39a2cd2e47ca7565f395d73617a813861c` |

Test configuration on this chain: voting delay 60 s, minimum period 10 min (plain) / 20 min (payment), timelock 5 min,
grace period 14 days, quorum ≥ 2 people, cap 5 000 tWBLOZ per vote, holding period 0 blocks. Mainnet values would be
days, not minutes.

A deployment on the BNB Smart Chain testnet (chain 97, visible on testnet.bscscan.com) is prepared and will be added
here once the deployer wallet has test BNB.

## Verify it yourself

1. Sources: [`contracts/`](contracts/) in this folder (MIT). Compiler `solc 0.8.24`, optimizer on (200 runs), EVM `paris`,
   OpenZeppelin Contracts 5.1.
2. Compile with Hardhat using those settings and compare the deployed runtime bytecode (`eth_getCode` on the public RPC)
   with your build; the treasury clones are EIP-1167 minimal proxies of the implementation above.
3. Read the rules on chain: `WBLOZ()` returns the test wBLOZ address, `maxAmount(0x0…0)` is `0` (BNB can never be paid),
   `config()` returns the periods above.
4. Follow a real run: the [test report](testnet-report-2026-10-31.md) lists every transaction hash (proposal, votes,
   payout) of the full test matrix, including the rejected votes that moved nothing and the negative tests.

## Not covered by this

The **Development Fund** is a different thing: a fixed share of every block reward goes to a public fund address, and
payments from it are decided by the project lead and sent manually, with no contract and no vote involved. Those
payments are listed on [bloz.org/community/fund](https://bloz.org/community/fund). See [dev-fund.md](../dev-fund.md).
