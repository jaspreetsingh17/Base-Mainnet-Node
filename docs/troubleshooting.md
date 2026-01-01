# Base Node Troubleshooting

## Common Issues

### op-geth Not Starting

**Solutions**:
1. Check JWT secret exists
2. Verify data directory
3. Check genesis initialization

```bash
# Check JWT
cat /var/lib/base/jwt.hex

# Check data directory
ls -la /var/lib/base/geth/

# View logs
sudo journalctl -u op-geth -n 100
```

### op-node Not Starting

**Solutions**:
1. Check L1 RPC connectivity
2. Verify L1 Beacon endpoint
3. Check op-geth is running

```bash
# Check L1 RPC
curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    ${L1_RPC_URL}

# Check L1 Beacon
curl ${L1_BEACON_URL}/eth/v1/beacon/headers/head

# View logs
sudo journalctl -u op-node -n 100
```

### Sync Issues

**Solutions**:
1. Download snapshot
2. Check L1 sync status
3. Verify sequencer connection

```bash
# Check sync status
curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
    http://localhost:8545

# Check op-node sync
curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"optimism_syncStatus","params":[],"id":1}' \
    http://localhost:9545
```

### L1 RPC Issues

**Solutions**:
1. Use reliable L1 provider
2. Check rate limits
3. Consider archive node for historical

Recommended L1 providers:
- Alchemy
- Infura
- QuickNode
- Self-hosted

### JWT Authentication Errors

```bash
# Regenerate JWT
openssl rand -hex 32 | sudo tee /var/lib/base/jwt.hex

# Ensure same JWT for both services
sudo chown base:base /var/lib/base/jwt.hex
sudo chmod 600 /var/lib/base/jwt.hex

# Restart both services
sudo systemctl restart op-geth op-node
```

## RPC Commands

### Standard Ethereum

```bash
# Block number
curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://localhost:8545

# Chain ID
curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
    http://localhost:8545

# Gas price
curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":1}' \
    http://localhost:8545

# Syncing status
curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
    http://localhost:8545
```

### OP Stack Specific

```bash
# Sync status (op-node)
curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"optimism_syncStatus","params":[],"id":1}' \
    http://localhost:9545

# Output root
curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"optimism_outputAtBlock","params":["latest"],"id":1}' \
    http://localhost:9545

# Rollup config
curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"optimism_rollupConfig","params":[],"id":1}' \
    http://localhost:9545
```

## Service Management

```bash
# Start both
sudo systemctl start op-geth op-node

# Stop both
sudo systemctl stop op-node op-geth

# Restart both
sudo systemctl restart op-geth op-node

# Check status
sudo systemctl status op-geth op-node
```

## Logs

```bash
# op-geth logs
sudo journalctl -u op-geth -f

# op-node logs
sudo journalctl -u op-node -f

# Both together
sudo journalctl -u op-geth -u op-node -f
```

## Metrics

```bash
# op-node metrics
curl http://localhost:7300/metrics

# op-geth metrics
curl http://localhost:6060/debug/metrics/prometheus
```

## Resources

- Docs: https://docs.base.org/
- Explorer: https://basescan.org/
- GitHub: https://github.com/base-org/node
