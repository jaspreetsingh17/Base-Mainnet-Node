# Base Node Deployment

Complete guide for deploying a Base (Coinbase L2) full node.

## Overview

Base is an Ethereum Layer 2 built on the OP Stack (Optimism). This guide covers running a Base full node using op-node and op-geth.

## Requirements

- Ubuntu 22.04 LTS or Debian 12
- 8 CPU cores
- 16GB RAM
- 1TB NVMe SSD
- Stable network connection
- Ethereum L1 RPC endpoint

## Architecture

```
+------------------+
|    op-geth       |
|  (Execution)     |
+--------+---------+
         |
+--------+---------+
|    op-node       |
|  (Consensus)     |
+--------+---------+
         |
+--------+---------+
|   Ethereum L1    |
+------------------+
```

## Quick Start

```bash
git clone https://github.com/jaspreetsingh17/Base-Mainnet-Node.git
cd base-node
chmod +x scripts/install.sh
./scripts/install.sh
```

For manual installation and configuration, see [docs/Manual-Setup.md](docs/Manual-Setup.md).

## Directory Structure

```
.
├── config/
│   ├── op-geth.toml
│   └── op-node.env
├── scripts/
│   ├── install.sh
│   ├── start.sh
│   ├── download-snapshot.sh
│   └── monitor.sh
├── docker/
│   └── docker-compose.yml
├── systemd/
│   ├── op-geth.service
│   └── op-node.service
└── docs/
    └── troubleshooting.md
```

## Components

### op-geth
- Execution layer client
- Fork of go-ethereum
- Processes transactions

### op-node
- Consensus layer client
- Derives blocks from L1
- Communicates with L1

## Ports

| Port | Purpose |
|------|---------|
| 8545 | HTTP RPC |
| 8546 | WebSocket |
| 9545 | op-node RPC |
| 7300 | Metrics |
| 30303 | P2P |

## Network Information

- Chain ID: 8453
- Native Token: ETH
- Block Time: 2 seconds

## License

MIT License
