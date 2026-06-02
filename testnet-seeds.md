# Block Zero Testnet – Seed Nodes

The testnet has two nodes: a **primary seed on the VPS** (always online) and a **local developer node** (mining, when online).

Add the primary seed to your `bitcoin.conf` under `[test]`:

```ini
[test]
addnode=217.160.46.61:18210
```

Optionally add the local node as a fallback:

```ini
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
addnode=217.160.46.61:18210
addnode=212.51.149.153:18210
```

Then start your node:

```bash
./build/bin/bitcoind -testnet -datadir=~/.bzero -daemon
./build/bin/bitcoin-cli -testnet -datadir=~/.bzero -rpcport=18211 getconnectioncount
./build/bin/bitcoin-cli -testnet -datadir=~/.bzero -rpcport=18211 getblockchaininfo
```

## Seed nodes

| Node | IP | Port | Role |
|---|---|---|---|
| **Primary seed (VPS)** | 217.160.46.61 | 18210 | Always-on seed; low resource use (~50 MB RAM) |
| Local node | 212.51.149.153 | 18210 | Developer node + mining (when online) |

Mining runs on the local machine only — the VPS seed accepts connections and relays the chain but does not mine.

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

Run a node with `listen=1` and forward TCP **18210** on your router. Share your public IP so others can add `addnode=YOUR_IP:18210`.
