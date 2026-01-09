Step 1: Clone the Repo
Ready to get started? First, you’ll need to clone the Base Node repository. Head over to the GitHub repo and clone it to your local machine.

git clone https://github.com/base-org/node
cd node

 

Step 2: Configure Your Environment
Now that you’ve got the repo, let’s set up the environment. You’ll need to ensure you have an Ethereum L1 full node RPC available. Set OP_NODE_L1_ETH_RPC and OP_NODE_L1_BEACON in the .env.* file.

If you’re running your own L1 node, make sure it’s fully synced. Base won’t sync until your L1 node is up to date.

We can use other public links for L1 RPC and L1 Beacon chain in .env.mainnet

Uncomment the line relevant to your network (.env.sepolia no need formainnet as its bydefault run.env.mainnet) under the 2 env_file keys in docker-compose.yml.
 

Step 3: Fire Up Docker
Time to bring your node to life! Run the following command to get everything up and running:

docker compose up -d

You can confirm your node is working by running:


curl -d '{"id":0,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
 -H "Content-Type: application/json" http://localhost:8545

If you get a response, congrats! Your node is officially alive.

 

 

Step 4: Speed Up with Snapshots (Optional)
Syncing your node can take days—yes, days. To save some time, you can restore from a snapshot. Here’s how:
 
 (chaindata folder in your geth-data have all node data)

Create a Data Folder:

In your Base Node directory, create a folder named geth-data or reth-data.
 

Fetch the Snapshot:

Use the following command to download the latest snapshot for your network:

wget https://mainnet-full-snapshots.base.org/$(curl https://mainnet-full-snapshots.base.org/latest)
 

Untar and Place:

Untar the snapshot and place the geth subfolder inside geth-data.
 

Restart Your Node:

cd ..
docker compose up --build

Your node should now start syncing from the last block in the snapshot.