#!/bin/bash

# Base Node Monitoring Script

RPC_URL="http://localhost:8545"
OP_NODE_URL="http://localhost:9545"

while true; do
    clear
    echo "=========================================="
    echo "          Base Node Monitor"
    echo "=========================================="
    echo ""
    
    # Check services
    GETH_STATUS="Stopped"
    NODE_STATUS="Stopped"
    
    if systemctl is-active --quiet op-geth; then
        GETH_STATUS="Running"
    fi
    
    if systemctl is-active --quiet op-node; then
        NODE_STATUS="Running"
    fi
    
    echo "SERVICE STATUS"
    echo "--------------"
    echo "op-geth: ${GETH_STATUS}"
    echo "op-node: ${NODE_STATUS}"
    
    if [ "$GETH_STATUS" != "Running" ] || [ "$NODE_STATUS" != "Running" ]; then
        echo ""
        echo "WARNING: Not all services are running!"
        sleep 5
        continue
    fi
    
    # Chain Info
    echo ""
    echo "CHAIN INFO"
    echo "----------"
    
    CHAIN_ID=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
        ${RPC_URL} 2>/dev/null | jq -r '.result')
    
    if [ -n "$CHAIN_ID" ] && [ "$CHAIN_ID" != "null" ]; then
        echo "Chain ID: $((16#${CHAIN_ID:2})) (Base)"
    fi
    
    # Sync Status
    echo ""
    echo "SYNC STATUS"
    echo "-----------"
    
    BLOCK=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
        ${RPC_URL} 2>/dev/null | jq -r '.result')
    
    if [ -n "$BLOCK" ] && [ "$BLOCK" != "null" ]; then
        BLOCK_DEC=$((16#${BLOCK:2}))
        echo "L2 Block: ${BLOCK_DEC}"
    fi
    
    # Sync check
    SYNC=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
        ${RPC_URL} 2>/dev/null | jq -r '.result')
    
    if [ "$SYNC" == "false" ]; then
        echo "Synced: Yes"
    else
        echo "Synced: No (syncing...)"
        if [ "$SYNC" != "null" ] && [ -n "$SYNC" ]; then
            CURRENT=$(echo $SYNC | jq -r '.currentBlock' 2>/dev/null)
            HIGHEST=$(echo $SYNC | jq -r '.highestBlock' 2>/dev/null)
            if [ -n "$CURRENT" ] && [ -n "$HIGHEST" ]; then
                echo "Progress: ${CURRENT}/${HIGHEST}"
            fi
        fi
    fi
    
    # op-node sync status
    echo ""
    echo "OP-NODE STATUS"
    echo "--------------"
    
    OP_SYNC=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"optimism_syncStatus","params":[],"id":1}' \
        ${OP_NODE_URL} 2>/dev/null | jq '.result')
    
    if [ -n "$OP_SYNC" ] && [ "$OP_SYNC" != "null" ]; then
        UNSAFE_L2=$(echo $OP_SYNC | jq -r '.unsafe_l2.number')
        SAFE_L2=$(echo $OP_SYNC | jq -r '.safe_l2.number')
        FINALIZED=$(echo $OP_SYNC | jq -r '.finalized_l2.number')
        
        echo "Unsafe L2: ${UNSAFE_L2:-N/A}"
        echo "Safe L2: ${SAFE_L2:-N/A}"
        echo "Finalized: ${FINALIZED:-N/A}"
    fi
    
    # Gas Price
    echo ""
    echo "GAS"
    echo "---"
    
    GAS=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":1}' \
        ${RPC_URL} 2>/dev/null | jq -r '.result')
    
    if [ -n "$GAS" ] && [ "$GAS" != "null" ]; then
        GAS_DEC=$((16#${GAS:2}))
        GAS_GWEI=$(echo "scale=6; $GAS_DEC / 1000000000" | bc)
        echo "Gas Price: ${GAS_GWEI} Gwei"
    fi
    
    # Network
    echo ""
    echo "NETWORK"
    echo "-------"
    
    PEERS=$(curl -s -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' \
        ${RPC_URL} 2>/dev/null | jq -r '.result')
    
    if [ -n "$PEERS" ] && [ "$PEERS" != "null" ]; then
        echo "Peers: $((16#${PEERS:2}))"
    fi
    
    # System Resources
    echo ""
    echo "SYSTEM"
    echo "------"
    
    GETH_PID=$(pgrep -f "op-geth" | head -1)
    if [ -n "$GETH_PID" ]; then
        MEM=$(ps -o rss= -p $GETH_PID | awk '{printf "%.1f GB", $1/1024/1024}')
        echo "op-geth Memory: ${MEM}"
    fi
    
    NODE_PID=$(pgrep -f "op-node" | head -1)
    if [ -n "$NODE_PID" ]; then
        MEM=$(ps -o rss= -p $NODE_PID | awk '{printf "%.1f GB", $1/1024/1024}')
        echo "op-node Memory: ${MEM}"
    fi
    
    echo ""
    echo "STORAGE"
    echo "-------"
    du -sh /var/lib/base 2>/dev/null | awk '{print "Data: " $1}'
    df -h /var/lib/base | tail -1 | awk '{print "Disk Free: " $4}'
    
    echo ""
    echo "Last updated: $(date)"
    echo "Press Ctrl+C to exit"
    
    sleep 30
done
