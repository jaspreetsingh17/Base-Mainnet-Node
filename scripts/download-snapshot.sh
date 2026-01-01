#!/bin/bash

# Download Base Snapshot

set -e

DATA_DIR="/var/lib/base"

echo "Base Snapshot Download"
echo "======================"
echo ""

# Stop nodes if running
if systemctl is-active --quiet op-node; then
    echo "Stopping op-node..."
    sudo systemctl stop op-node
fi

if systemctl is-active --quiet op-geth; then
    echo "Stopping op-geth..."
    sudo systemctl stop op-geth
fi

echo ""
echo "Select snapshot source:"
echo "1) Base official snapshots"
echo "2) Custom URL"
read -p "Enter choice (1/2): " CHOICE

case $CHOICE in
    1)
        echo ""
        echo "Downloading from Base official snapshots..."
        
        # Get latest snapshot URL
        SNAPSHOT_URL=$(curl -s https://base-snapshots-mainnet.s3.amazonaws.com/latest)
        
        if [ -z "$SNAPSHOT_URL" ]; then
            echo "Could not find latest snapshot. Using default URL..."
            SNAPSHOT_URL="https://base-snapshots-mainnet.s3.amazonaws.com/mainnet-geth.tar.zst"
        fi
        
        # Backup existing data
        if [ -d "${DATA_DIR}/geth/geth" ]; then
            echo "Backing up existing data..."
            sudo mv ${DATA_DIR}/geth/geth ${DATA_DIR}/geth/geth.backup.$(date +%Y%m%d)
        fi
        
        # Install zstd if needed
        if ! command -v zstd &> /dev/null; then
            sudo apt install -y zstd
        fi
        
        # Download and extract
        cd /tmp
        echo "Downloading snapshot (this may take a while)..."
        wget -q --show-progress ${SNAPSHOT_URL} -O base-snapshot.tar.zst
        
        echo "Extracting snapshot..."
        zstd -d base-snapshot.tar.zst
        sudo tar -xf base-snapshot.tar -C ${DATA_DIR}/geth/
        
        # Cleanup
        rm base-snapshot.tar.zst base-snapshot.tar
        ;;
    2)
        read -p "Enter snapshot URL: " SNAPSHOT_URL
        
        cd /tmp
        wget -q --show-progress ${SNAPSHOT_URL} -O snapshot.tar
        sudo tar -xf snapshot.tar -C ${DATA_DIR}/geth/
        rm snapshot.tar
        ;;
esac

# Set permissions
sudo chown -R base:base ${DATA_DIR}

echo ""
echo "Snapshot restored successfully!"
echo "Start nodes with: ./scripts/start.sh"
