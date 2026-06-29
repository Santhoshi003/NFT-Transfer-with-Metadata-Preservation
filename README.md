# NFT Transfer with Metadata Preservation

This project implements a cross-chain NFT bridge using Chainlink CCIP with metadata preservation. The system allows an NFT to be burned on the source chain and minted on the destination chain while preserving the token metadata such as the token ID and token URI.

The project combines:
- Solidity smart contracts for the NFT and bridge logic
- Foundry for contract development, compilation, and testing
- A Node.js CLI for initiating transfers
- Docker and Docker Compose for running the CLI environment consistently

---

## Project Overview

In a multi-chain ecosystem, NFTs are often isolated to a single blockchain. This bridge enables interoperability by transferring NFTs across chains in a secure and structured way.

The implementation follows the common burn-and-mint pattern:
1. The NFT is burned on the source chain.
2. A CCIP message is sent to the destination chain.
3. The destination bridge mints a new NFT with the same token ID and metadata.

This project is designed to be a production-ready foundation for:
- Cross-chain NFT transfers
- Metadata preservation across networks
- Integration with Chainlink CCIP
- CLI-based backend interaction for blockchain workflows

---

## Architecture

### Smart Contracts
- CrossChainNFT.sol
  - ERC-721 compatible NFT contract
  - Minting is restricted to the bridge contract
  - Includes bridge configuration and burn functionality

- CCIPNFTBridge.sol
  - Handles cross-chain message transmission
  - Sends NFT transfer messages through the CCIP router
  - Receives CCIP messages and mints NFTs on the destination chain

### CLI Tool
- Built with Node.js
- Uses ethers.js
- Parses arguments such as token ID, source chain, destination chain, and receiver
- Logs transfer activity to a file
- Stores transfer records in JSON format

### Containerization
- Dockerfile provides a Node.js runtime environment
- docker-compose.yml starts the CLI environment in a container

---

## Tech Stack

- Solidity
- Foundry
- Node.js
- ethers.js
- Docker
- Docker Compose
- Chainlink CCIP

---

## Folder Structure

```text
src/                 # Solidity smart contracts
script/              # Foundry deployment scripts
cli/                 # CLI tool
data/                # Transfer records JSON
logs/                # Transfer logs
test/                # Foundry tests
Dockerfile           # Container definition
docker-compose.yml   # Container orchestration
foundry.toml         # Foundry configuration
package.json         # Node.js dependencies and scripts
.env.example         # Environment variable template
deployment.json      # Deployment addresses for testnets
```

---

## Prerequisites

Before running the project, ensure you have:

- Node.js installed
- npm installed
- Foundry installed
- Docker and Docker Compose installed
- Testnet funds for the relevant chains
- LINK tokens for CCIP transactions if required by your environment

---

## Environment Variables

Copy .env.example to .env and fill in the required values:

```env
PRIVATE_KEY=
FUJI_RPC_URL=
ARBITRUM_SEPOLIA_RPC_URL=
CCIP_ROUTER_FUJI=
CCIP_ROUTER_ARBITRUM_SEPOLIA=
LINK_TOKEN_FUJI=
LINK_TOKEN_ARBITRUM_SEPOLIA=
```

These values are required for:
- contract deployment
- CLI transaction submission
- cross-chain transfer execution

---

## Installation

### Install Node dependencies

```bash
npm install
```

### Install Foundry dependencies

```bash
forge build
```

---

## Contract Build

```bash
forge build
```

---

## Running the CLI

Run the CLI with:

```bash
npm run transfer -- --tokenId=1 --from=avalanche-fuji --to=arbitrum-sepolia --receiver=<receiver-address>
```

### Example

```bash
npm run transfer -- --tokenId=1 --from=avalanche-fuji --to=arbitrum-sepolia --receiver=0x0000000000000000000000000000000000000000
```

The CLI will:
- parse the transfer arguments
- connect to the source chain RPC
- submit the bridge transaction
- log the operation
- save a structured transfer record

---

## Docker Usage

Build and start the container:

```bash
docker-compose up -d --build
```

To access the container:

```bash
docker exec -it ccip-nft-bridge-cli sh
```

---

## Deployment

The deployment script is located in:

```text
script/Deploy.s.sol
```

Update the deployment addresses in deployment.json after deploying the contracts.

---

## Transfer Logging

The CLI writes logs to:

```text
logs/transfers.log
```

It also stores structured transfer records in:

```text
data/nft_transfers.json
```

---

## Notes

- The bridge uses a burn-and-mint mechanism for cross-chain NFT transfer.
- Metadata such as the token URI is preserved by carrying it in the CCIP message.
- The implementation is designed to be extended for production-grade deployments with proper router configuration and real chain deployment addresses.

---

## Summary

This repository provides a complete starting point for building and experimenting with a Chainlink CCIP-based NFT bridge, including:
- bridge smart contracts
- deployment support
- CLI interaction
- Docker environment
- logging and transfer record management
