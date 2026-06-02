# Block Zero Testnet – Seed Node

The Block Zero testnet seed node runs on the developer machine (always-on when online).
Add it to your `bitcoin.conf` under `[test]`:

```ini
[test]
addnode=212.51.149.153:18210
```

## Quick start (bitcoin.conf)

```ini
server=1
listen=1
txindex=1

[test]
bind=0.0.0.0:18210
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
rpcport=18211
addnode=212.51.149.153:18210
```

Then start your node:

```bash
./build/bin/bitcoind -testnet -datadir=~/.bzero -daemon
./build/bin/bitcoin-cli -testnet -datadir=~/.bzero -rpcport=18211 getconnectioncount
./build/bin/bitcoin-cli -testnet -datadir=~/.bzero -rpcport=18211 getblockchaininfo
```

## Seed node

| Node | IP | Port | Notes |
|---|---|---|---|
| Primary seed | 212.51.149.153 | 18210 | Developer machine; online when testnet is active |

The seed node intentionally runs locally (not on the production VPS) to avoid competing with hosted websites for RAM and CPU.

## Network parameters

| Property | Value |
|---|---|
| Network magic | `b1 0c 74 45` |
| P2P port | 18210 |
| RPC port | 18211 |
| Bech32 HRP | `tbz` |
| PoW | RandomX (CPU-friendly) |
| Genesis hash | `f58130b19cdf3d03b22c5a67a6509b00750b2d8975ee9d889d5b613aaae5296e` |
| Genesis nBits | `0x1e3fffff` |
| powLimit | `0x1e3fffff` |
| Retarget interval | 12 hours (72 blocks) |

## Verify connectivity

```bash
bitcoin-cli -testnet -datadir=~/.bzero -rpcport=18211 getconnectioncount
bitcoin-cli -testnet -datadir=~/.bzero -rpcport=18211 getblockhash 0
# Expected: f58130b19cdf3d03b22c5a67a6509b00750b2d8975ee9d889d5b613aaae5296e
```

## Running your own seed node

If you want to help the network, run a node with `listen=1` and forward TCP **18210** on your router to your machine. Then share your public IP so others can add `addnode=YOUR_IP:18210`.
