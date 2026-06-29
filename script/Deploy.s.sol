// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {CrossChainNFT} from "../src/CrossChainNFT.sol";
import {CCIPNFTBridge} from "../src/CCIPNFTBridge.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address router = vm.envAddress("CCIP_ROUTER_FUJI");
        address link = vm.envAddress("LINK_TOKEN_FUJI");

        vm.startBroadcast(deployerPrivateKey);
        CrossChainNFT nft = new CrossChainNFT("CCIP NFT", "CCIPNFT", deployer);
        CCIPNFTBridge bridge = new CCIPNFTBridge(router, link, address(nft), deployer);
        nft.setBridge(address(bridge));
        vm.stopBroadcast();

        vm.toString(address(nft));
        vm.toString(address(bridge));
    }
}
