#!/bin/bash

# Base Node Installation Script
# Tested on Ubuntu 22.04 LTS

set -e

DATA_DIR="/var/lib/base"
CONFIG_DIR="/etc/base"
OP_GETH_VERSION="v1.101308.1"
OP_NODE_VERSION="v1.4.0"

echo "Installing Base Node..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y \
    wget \
    curl \
    jq \
    git \
    openssl

# Create base user
if ! id "base" &>/dev/null; then
    sudo useradd -r -m -s /bin/bash base
fi

# Create directories
sudo mkdir -p ${DATA_DIR}/geth
sudo mkdir -p ${CONFIG_DIR}
sudo mkdir -p /var/log/base

# Generate JWT secret
echo "Generating JWT secret..."
openssl rand -hex 32 | sudo tee ${DATA_DIR}/jwt.hex > /dev/null

# Download op-geth
echo "Downloading op-geth..."
cd /tmp
wget -q https://github.com/ethereum-optimism/op-geth/releases/download/${OP_GETH_VERSION}/op-geth-linux-amd64 -O op-geth
chmod +x op-geth
sudo mv op-geth /usr/local/bin/

# Download op-node
echo "Downloading op-node..."
wget -q https://github.com/ethereum-optimism/optimism/releases/download/${OP_NODE_VERSION}/op-node-linux-amd64 -O op-node
chmod +x op-node
sudo mv op-node /usr/local/bin/

# Verify installation
op-geth version
op-node --version

# Download rollup config
echo "Downloading Base rollup config..."
wget -q https://raw.githubusercontent.com/base-org/node/main/mainnet/rollup.json -O rollup.json
sudo mv rollup.json ${CONFIG_DIR}/

# Download genesis
echo "Downloading genesis..."
wget -q https://raw.githubusercontent.com/base-org/node/main/mainnet/genesis-l2.json -O genesis-l2.json

# Initialize op-geth
echo "Initializing op-geth..."
sudo -u base op-geth init --datadir=${DATA_DIR}/geth genesis-l2.json
rm genesis-l2.json

# Copy configurations
sudo cp ../config/op-geth.toml ${CONFIG_DIR}/op-geth.toml
sudo cp ../config/op-node.env ${CONFIG_DIR}/op-node.env

# Prompt for L1 RPC
echo ""
read -p "Enter Ethereum L1 RPC URL: " L1_RPC
read -p "Enter Ethereum Beacon RPC URL: " BEACON_RPC

sudo sed -i "s|https://eth-mainnet.example.com|${L1_RPC}|g" ${CONFIG_DIR}/op-node.env
sudo sed -i "s|https://eth-beacon.example.com|${BEACON_RPC}|g" ${CONFIG_DIR}/op-node.env

# Set permissions
sudo chown -R base:base ${DATA_DIR}
sudo chown -R base:base ${CONFIG_DIR}
sudo chown -R base:base /var/log/base

# Install systemd services
sudo cp ../systemd/op-geth.service /etc/systemd/system/
sudo cp ../systemd/op-node.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable op-geth op-node

# Configure firewall
sudo ufw allow 8545/tcp
sudo ufw allow 8546/tcp
sudo ufw allow 30303/tcp
sudo ufw allow 30303/udp
sudo ufw allow 9222/tcp
sudo ufw allow 9222/udp

echo ""
echo "Installation complete!"
echo ""
echo "For faster sync, download a snapshot:"
echo "  ./scripts/download-snapshot.sh"
echo ""
echo "Start the node with: ./scripts/start.sh"
echo "Or manually:"
echo "  sudo systemctl start op-geth"
echo "  sudo systemctl start op-node"
