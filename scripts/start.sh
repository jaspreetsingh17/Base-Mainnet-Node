#!/bin/bash

# Start Base Node

set -e

echo "Starting Base Node..."

# Start op-geth first
echo "Starting op-geth..."
sudo systemctl start op-geth

# Wait for op-geth to initialize
echo "Waiting for op-geth..."
sleep 10

# Start op-node
echo "Starting op-node..."
sudo systemctl start op-node

# Wait for full startup
echo "Waiting for nodes to sync..."
sleep 15

# Check status
echo ""
if systemctl is-active --quiet op-geth && systemctl is-active --quiet op-node; then
    echo "Base node started successfully!"
    echo ""
    
    # Check block
    BLOCK=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
        http://localhost:8545 2>/dev/null | jq -r '.result')
    
    if [ -n "$BLOCK" ] && [ "$BLOCK" != "null" ]; then
        BLOCK_DEC=$((16#${BLOCK:2}))
        echo "Current Block: ${BLOCK_DEC}"
    else
        echo "Node is initializing..."
    fi
    
    echo ""
    echo "HTTP RPC: http://localhost:8545"
    echo "WebSocket: ws://localhost:8546"
    echo "op-node RPC: http://localhost:9545"
else
    echo "Failed to start Base node"
    echo ""
    echo "op-geth status:"
    systemctl is-active op-geth || true
    echo ""
    echo "op-node status:"
    systemctl is-active op-node || true
    echo ""
    echo "Check logs:"
    echo "  sudo journalctl -u op-geth -n 30"
    echo "  sudo journalctl -u op-node -n 30"
    exit 1
fi
