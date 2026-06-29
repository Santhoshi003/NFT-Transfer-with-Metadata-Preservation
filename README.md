# Chainlink CCIP Cross-Chain NFT Transfer

This repository contains a Foundry-based Solidity implementation of a Chainlink CCIP NFT bridge together with a Node.js CLI for initiating transfers and recording transfer state.

## What is included
- CrossChainNFT: an ERC-721 NFT contract with bridge-controlled minting and owner-only bridge configuration.
- CCIPNFTBridge: a CCIP-compatible bridge contract that burns NFTs on the source chain and mints them on the destination chain.
- CLI: a Node.js entry point that parses transfer arguments, writes logs, and appends transfer records.
- Docker support: a containerized CLI runtime that can be launched with docker-compose.

## Project layout
- src/: Solidity contracts
- script/: Foundry deployment script
- cli/: Node.js CLI tool
- data/: transfer record storage
- logs/: transfer logs

## Pre-minted test NFT
- Token ID: 1
- Initial owner: the deployer wallet derived from PRIVATE_KEY
- This is documented so the CLI can be used with a known NFT during live deployment.

## Required environment variables
Populate the environment values from .env.example before running the CLI or deployment script.

## CLI usage
```bash
npm run transfer -- --tokenId=1 --from=avalanche-fuji --to=arbitrum-sepolia --receiver=0x0000000000000000000000000000000000000000
```

## Docker usage
```bash
docker-compose up -d --build
```
