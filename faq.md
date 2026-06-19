# Block Zero FAQ

## What is Block Zero?

**Modern BTC code. A second chance at Genesis.**

Block Zero is an independent proof-of-work chain — built on Bitcoin Core v31, mined with RandomX on ordinary CPUs, launched with no presale, no premine, and no insider allocation. Fair from block one.

## Is this Bitcoin?

No. Block Zero is **not** Bitcoin. It is an independent network inspired by the early Bitcoin era.

## Is BLOZ an investment?

No promises of any kind. BLOZ has no guaranteed value, liquidity, or expected return.

## Why RandomX instead of SHA-256?

SHA-256 is dominated by ASICs. RandomX is optimized for CPUs and resists ASICs/GPUs — ordinary hardware can participate.

## Do I need a GPU?

No. RandomX is CPU-bound. A modern multi-core CPU is what matters.

## Was there a premine or ICO?

No. Genesis carries no spendable allocation. Coins are mined after launch. Genesis is reproducible from public source — see [genesis-spec.md](genesis-spec.md).

## Genesis block hashes

- **Mainnet:** `44c1a8c852b3eda21966e1ddb6b0807e22488dffe8a270bf24bf1fa2d66c13bd` (2026-06-06)
- **Testnet:** `7462293eec16a92c54a74362af6825688135e2955250024dcc3668ff4f55cfce`

## Difficulty & supply

- RandomX PoW with height-based seed key rotation
- ~10 minute block spacing
- Difficulty retargets every ~12 hours (72 blocks)
- 21M cap, halvings — same scarcity model as Bitcoin

---

## Getting started

| I want to… | Read |
|------------|------|
| Set up the wallet | [how-to-use-wallet.md](how-to-use-wallet.md) |
| Start mining | [how-to-mine.md](how-to-mine.md) |
| Use scripts / alternatives | [quickstart-mining.md](quickstart-mining.md) |
| Run a node | [node-guide.md](node-guide.md) |
| Understand mining | [mining-guide.md](mining-guide.md) |

**Pool mining:** get a `bz1` address → [how-to-mine.md](how-to-mine.md). No full node sync needed.

**Solo mining:** sync first (`Peers ≥ 1`) → [how-to-mine.md § Solo](how-to-mine.md#3-solo-mining--run-your-own-node).

**Do I need a seed node?** No. `addnode=217.160.46.61:8210` is in the default config.

**Can I use a Bitcoin (`bc1`) address?** No — BLOZ uses **`bz1`** addresses only.

---

## Troubleshooting (install & first run)

Always download the **[latest release](https://github.com/Rexemre/blockzero-core/releases/latest)**.

### macOS: "Block Zero is damaged and can't be opened"

Gatekeeper, not corruption. Fix:

```bash
curl -fsSL https://raw.githubusercontent.com/Rexemre/blockzero-ops/main/scripts/mainnet/install-macos.sh | bash
# or manually:
xattr -dr com.apple.quarantine "$HOME/Applications/Block Zero.app"
```

Then **Right-click → Open**. Details: [how-to-use-wallet.md](how-to-use-wallet.md).

### macOS: `filesystem error: in equivalent`

First-run bug in older builds. Download the latest release.

### Prune mode is incompatible with `-txindex`

Remove the `txindex` line from `bitcoin.conf`:

| OS | Path |
|----|------|
| Windows | `%LOCALAPPDATA%\BlockZeroMainnet\bitcoin.conf` |
| macOS (script) | `~/.blockzero-mainnet/bitcoin.conf` |
| macOS (direct) | `~/Library/Application Support/BlockZeroMainnet/bitcoin.conf` |

Or download the latest release (new installs no longer add `txindex`).

### Windows: `Qt6Gui.dll` / `Qt6Widgets.dll` not found

**Extract the zip first** → run **`Start Block Zero.bat`**. Do not launch from inside the zip.

### Threads / rig name when mining

See [how-to-mine.md § Options](how-to-mine.md#options--threads-rig-name--more).

### Low hashrate (EPYC / big servers)

RandomX needs **huge pages**. Run Linux installer with `sudo`, or `sudo ./mine-pool.sh`. See [mining-guide.md § Performance](mining-guide.md#performance-and-huge-pages).

### Sync stuck / 0 peers

Add to `bitcoin.conf`: `addnode=217.160.46.61:8210` — see [how-to-use-wallet.md § Sync](how-to-use-wallet.md#6-sync--peers).

### Linux server: wallet / `libQt6Widgets.so.6` missing

Use **CLI** on headless servers — no GUI, no Qt. See [how-to-use-wallet.md § Linux](how-to-use-wallet.md#-linux). The GUI binary (`bin/block-zero`) needs Qt6 libs + a display; CLI is the normal server setup.

---

## Where is the code?

Open source: [blockzero-core](https://github.com/Rexemre/blockzero-core) (Bitcoin Core v31 fork). Upstream pinned in `UPSTREAM.md`.
