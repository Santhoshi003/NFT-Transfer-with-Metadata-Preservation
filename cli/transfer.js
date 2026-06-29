#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { ethers } = require('ethers');
require('dotenv').config();

function parseArgs(argv) {
  const parsed = {};
  for (const arg of argv) {
    if (!arg.startsWith('--')) continue;
    const [key, value] = arg.slice(2).split('=');
    parsed[key] = value;
  }
  return parsed;
}

function ensureDirectory(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function appendLog(message) {
  ensureDirectory(path.join(__dirname, '..', 'logs'));
  const logFile = path.join(__dirname, '..', 'logs', 'transfers.log');
  fs.appendFileSync(logFile, `${new Date().toISOString()} ${message}\n`);
}

function updateTransfers(payload) {
  const dataFile = path.join(__dirname, '..', 'data', 'nft_transfers.json');
  ensureDirectory(path.dirname(dataFile));
  let records = [];
  if (fs.existsSync(dataFile)) {
    records = JSON.parse(fs.readFileSync(dataFile, 'utf8'));
  }
  records.push(payload);
  fs.writeFileSync(dataFile, JSON.stringify(records, null, 2));
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const tokenId = args.tokenId;
  const from = args.from;
  const to = args.to;
  const receiver = args.receiver;

  if (!tokenId || !from || !to || !receiver) {
    throw new Error('Usage: npm run transfer -- --tokenId=<id> --from=<chain> --to=<chain> --receiver=<address>');
  }

  appendLog(`Starting transfer tokenId=${tokenId} from=${from} to=${to} receiver=${receiver}`);

  const chainKey = from === 'avalanche-fuji' ? 'avalancheFuji' : 'arbitrumSepolia';
  const rpcUrl = from === 'avalanche-fuji' ? process.env.FUJI_RPC_URL : process.env.ARBITRUM_SEPOLIA_RPC_URL;
  if (!rpcUrl) {
    throw new Error('Missing RPC URL in environment');
  }

  const provider = new ethers.JsonRpcProvider(rpcUrl);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  const deployment = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'deployment.json'), 'utf8'));
  const bridgeAddress = deployment[chainKey].bridgeContractAddress;

  const abi = [
    'function sendNFT(uint64 destinationChainSelector, address receiver, uint256 tokenId) external returns (bytes32)'
  ];
  const bridge = new ethers.Contract(bridgeAddress, abi, wallet);

  const messageId = await bridge.sendNFT(16015286601757825753, receiver, tokenId);
  appendLog(`Submitted transaction messageId=${messageId}`);
  const tx = await bridge.provider.getTransaction(messageId);
  appendLog(`Submitted transaction hash=${tx?.hash || 'pending'}`);
  const receipt = await tx?.wait?.();
  appendLog(`Mined tx hash=${receipt?.hash || 'pending'} status=${receipt?.status ?? 'pending'}`);

  const transferRecord = {
    transferId: crypto.randomUUID(),
    tokenId,
    sourceChain: from,
    destinationChain: to,
    sender: wallet.address,
    receiver,
    ccipMessageId: messageId,
    sourceTxHash: receipt?.hash || null,
    destinationTxHash: null,
    status: 'initiated',
    metadata: {
      name: 'CCIP NFT',
      description: 'Cross-chain NFT transfer',
      image: 'https://example.com/nft.png'
    },
    timestamp: new Date().toISOString()
  };

  updateTransfers(transferRecord);
  console.log(JSON.stringify({ txHash: receipt?.hash || null, status: 'initiated' }, null, 2));
}

main().catch((error) => {
  appendLog(`ERROR ${error.message}`);
  console.error(error.message);
  process.exit(1);
});
