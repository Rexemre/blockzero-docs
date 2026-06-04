# Block Zero testnet genesis (2026-06-04)

The Block Zero testnet runs on a RandomX proof-of-work genesis block with a
Satoshi-style coinbase headline. **Mainnet genesis is separate and unchanged
until launch.**

## Genesis message

```text
The Times 04/Jun/2026 Block Zero - a second chance at Genesis
```

| Field | Value |
|-------|-------|
| `nTime` | `1780531200` (2026-06-04 00:00:00 UTC) |
| `nBits` | `0x1e3fffff` |
| nonce | `244191` |
| **genesis hash** | `7462293eec16a92c54a74362af6825688135e2955250024dcc3668ff4f55cfce` |
| merkle root | `dde7404a2458cd54b4ac603bf860a919f499c47f9b0d00cb27ee0ed59196b9a2` |

Full values: [testnet.json](https://github.com/Rexemre/blockzero-core/blob/main/artifacts/genesis/testnet.json).

---

## Reproduce the genesis

```powershell
cd blockzero-core
# Build bz-genesis-miner once (Visual Studio + CMake), or use a release that ships it:
cmake -B build --preset vs2026-static
cmake --build build --config Release --target bz-genesis-miner

.\scripts\genesis\mine-testnet-genesis.ps1
.\scripts\genesis\apply-testnet-genesis.ps1 -LogFile genesis-mine.log
```

Verify the node boots on the genesis:

```powershell
.\build\bin\Release\bitcoind.exe -testnet -datadir=$env:TEMP\bz-verify -daemon
.\build\bin\Release\bitcoin-cli.exe -testnet -datadir=$env:TEMP\bz-verify getblockhash 0
# must equal 7462293eec16a92c54a74362af6825688135e2955250024dcc3668ff4f55cfce
```

---

## Reset a node to the current testnet genesis

If a node was previously on an older/solo chain, wipe its chain data so it boots
on the published genesis. The wallet is kept.

### Local miner (Windows)

```powershell
cd blockzero-ops\scripts\testnet
.\mine-testnet.ps1 -Stop
.\resync-testnet.ps1
.\mine-testnet.ps1 -Status   # Peers >= 1, genesis hash matches
.\mine-testnet.ps1           # mine the next block on the public chain
```

### VPS seed (217.160.46.61)

```bash
ssh root@217.160.46.61
systemctl stop blockzero-testnet blockzero-explorer
# Wipe chain + stale indexes (keep config + wallet)
rm -rf /opt/bzero-testnet/testnet3/blocks \
       /opt/bzero-testnet/testnet3/chainstate \
       /opt/bzero-testnet/testnet3/indexes \
       /opt/bzero-testnet/testnet3/peers.dat
cd /opt/blockzero-core && git pull && cmake --build build -j$(nproc) --target bitcoind
systemctl start blockzero-testnet
/opt/blockzero-core/build/bin/bitcoin-cli -testnet -datadir=/opt/bzero-testnet getblockhash 0
# must equal the genesis hash above
systemctl start blockzero-explorer
```

> If the service fails to start with "Cannot obtain a lock", a stray `bitcoind`
> is still running - `pkill -f 'bitcoind -testnet'` and start again.
> If it fails with "best block of txindex not found", delete `testnet3/indexes`.

---

## Notes

- Block 1 is **not** fixed; it is mined fresh on the public network after genesis.
- A testnet reset invalidates previously mined TBLOZ - expected and harmless.
- Why a Satoshi-style message? It anchors the launch date in a public, verifiable
  way, in the spirit of Bitcoin's original genesis coinbase.
