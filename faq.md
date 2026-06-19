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

See [quickstart-mining.md](quickstart-mining.md) (pool or solo), [node-guide.md](node-guide.md), and [mining-guide.md](mining-guide.md).

**Pool (recommended):** `install-windows.ps1` then `mine-mainnet.ps1 -Pool` — no full sync needed to mine.

**Solo:** same wallet setup, but sync first (`Peers >= 1`) before mining.

## Do I need a node, wallet, or seed to pool mine?

- **Wallet:** yes — created automatically by `mine-mainnet.ps1` (not by `install-windows.ps1`).
- **Local node:** started briefly for wallet creation; you do not need to stay fully synced to pool mine.
- **Seed node:** no — users never install seeds; `addnode=217.160.46.61:8210` is already in the default config.

## Troubleshooting (install & first run)

Always download the **[latest release](https://github.com/Rexemre/blockzero-core/releases/latest)** — older builds (rc28 and earlier) have launch bugs that are fixed in newer ones.

**macOS: "Block Zero is damaged and can't be opened. You should move it to the Bin."**
This is macOS Gatekeeper, not a real corruption (the app is ad-hoc signed, not notarized).
Easiest fix — install via the script, which clears it automatically:
```bash
cd blockzero-ops/scripts/mainnet && ./install-macos.sh --force
```
Or clear it manually, then open with **Right-click → Open**:
```bash
xattr -dr com.apple.quarantine "$HOME/Applications/Block Zero.app"
```

**macOS: `filesystem error: in equivalent: Operation not supported`**
A first-run bug in older builds. Fixed in the latest release — download it again.

**macOS / Windows: `Prune mode is incompatible with -txindex`**
You chose "limit block chain storage" (prune) on the welcome screen while the config had
`txindex`. Fixed in the latest release. To unblock an existing install, remove the `txindex`
line from `bitcoin.conf` (macOS: `~/Library/Application Support/BlockZeroMainnet/bitcoin.conf`).

**Windows: `Qt6Gui.dll` / `Qt6Widgets.dll` not found** (often a System Error you must reboot to clear)
**Extract the zip first** — right-click the `.zip` → *Extract All…* — then run the wallet from the
extracted folder (double-click **`Start Block Zero.bat`**, or `bin\Block Zero.exe`). Running it
straight from inside the zip launches the `.exe` without its DLLs and triggers this error. Always
keep `Block Zero.exe` next to its DLLs in `bin\`.

**Mining hashrate is very low (especially on EPYC / Threadripper / big servers)**
RandomX needs **huge pages**. Run `sudo ./mine-pool.sh ...` once so it can reserve them, and
check the miner shows `RandomX dataset using HUGE PAGES - full speed`. See the performance tip
in [quickstart-mining.md](quickstart-mining.md).

## Where is the code?

Everything is open source under `Rexemre/blockzero-core` (a fork of Bitcoin Core),
with the upstream baseline pinned and tracked for security updates.
