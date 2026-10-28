# Changelog

Notable changes to Block Zero (BLOZ) software and services. Newest first.

---

## What's new — October 2026

### Wallet & node ([blockzero-core releases](https://github.com/Rexemre/blockzero-core/releases))

No consensus or network changes in any of these releases. Each one is a safe drop-in upgrade.

| Release | Date | What changed |
|---------|------|--------------|
| **v1.0.0-rc38** (latest) | 2026-10-02 | Finishes the wording cleanup: RPC help and examples, CLI `-help` output, error and log messages, the Windows installer and its `bloz:` link handler now say Block Zero / BLOZ. The RPC smallest-unit abbreviation is now `rex`. Program names (`bitcoind`, `bitcoin-cli`, `bitcoin-qt`) and P2P constants are unchanged on purpose. |
| **v1.0.0-rc37** | 2026-09-29 | The smallest BLOZ unit is called **rex** in the wallet (instead of satoshi). Values do not change. |
| **v1.0.0-rc36** | 2026-09-29 | Sending works right after the first start: the wallet ships with a default fallback fee of 0.00001 BLOZ/kvB, so a fresh wallet no longer fails with *"Fee estimation failed. Fallbackfee is disabled."* `fallbackfee` in `bitcoin.conf` still overrides it. Build fix for the macOS release. |

Windows: the one-click installer `blockzero-windows-x64-setup.exe` is always attached to the latest release. See [How to Use the Wallet](how-to-use-wallet.md).

### Bridge (BLOZ ↔ wBLOZ, [bridge.bloz.org](https://bridge.bloz.org))

- **More reliable BSC polling:** the relayer reads BNB Smart Chain a few blocks behind the tip and fails over between public RPC endpoints, so short RPC hiccups no longer delay wraps or unwraps.
- **Unwrap address check:** the bridge page checks your `bz1…` receive address before you burn wBLOZ (`/api/validate-address`), and the relayer checks it again. An unwrap to an address that can never be paid (for example a typo that breaks the checksum) is no longer retried; it is parked and the wBLOZ is returned.
- **Reserve top-ups** sent by the team are recognised as reserve funding and are no longer treated as unknown deposits.
- **Monitoring:** an automatic health check runs every 5 minutes (relayer service, BSC scan position against on-chain unwrap IDs, open transfers, reserve against wBLOZ supply) and alerts the team.
- Fees are unchanged: **0% bridge fee**, unwrap payout = burned wBLOZ − 0.00001 BLOZ network fee. Details: [Bridge guide](bridge-guide.md).

### Mining pool ([pool.bloz.org](https://pool.bloz.org))

- **Orphan handling:** before a found block matures, the pool checks that the block is still part of the main chain. A block that was orphaned is marked as such and its pending credits are cancelled, so payouts only come from blocks that stay in the chain.
- **New dashboard numbers** (estimates, based on recent block times):
  - **Est. next block** for the whole network and for the pool,
  - **Current difficulty**,
  - **Next retarget**: the expected difficulty change at the next adjustment (every 72 blocks, change limited to 4×).
- Faster pool API under load. Pool terms unchanged: PPLNS, **0% pool fee**, minimum payout 0.5 BLOZ. Start here: [How to Mine BLOZ](how-to-mine.md).

### Community platform ([bloz.org/community](https://bloz.org/community/))

- **Projects are free.** Opening a project or group costs nothing (no fee, no subscription, no expiry) and goes live immediately. Older posts that mention 10 USD are outdated. Guide: [Community Projects](community-projects.md).
- **Verified badge:** connect your wallet (MetaMask login, one free signature), link Discord, and prove one BLOZ address by signing a short text with a **Legacy address** (starts with `B`; bz1… addresses cannot sign messages). Only Verified members can open a project. The badge is a profile marker, not an NFT and not an investment.
- **Joining options for groups and projects:** Open · Verified only · Request & approval · Verified + approval.
- **Ask AI:** the BLOZ assistant is available as a chat on bloz.org and the bridge page. Without login you get a few free questions per day (no memory); with a connected wallet you use your personal quota.
- **Reading images:** the assistant can read screenshots and forms in Discord and in the web chat (web chat: Verified members, up to 3 images per question). Images are not stored, and the assistant never asks for seed phrases or private keys.
- **English only:** the whole web interface is now in English; there is no language switch any more.
- **One header everywhere:** bloz.org, the community pages, pool, explorer and bridge share the same top navigation.

Help and guide on the site: https://bloz.org/community/help/

### Documentation

- New: [Community Projects](community-projects.md) (open a project, get verified, joining options).
- Fixed: pool fee in [quickstart-mining.md](quickstart-mining.md) (0%), Linux CLI download command in [how-to-use-wallet.md](how-to-use-wallet.md).
