// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CrossChainNFT} from "../src/CrossChainNFT.sol";
import {CCIPNFTBridge} from "../src/CCIPNFTBridge.sol";

contract CCIPNFTBridgeTest is Test {
    CrossChainNFT internal nft;
    CCIPNFTBridge internal bridge;

    address internal owner = address(0xBEEF);
    address internal receiver = address(0xCAFE);
    address internal router = address(0x1234);
    address internal link = address(0x5678);

    function setUp() public {
        nft = new CrossChainNFT("CCIP NFT", "CCIPNFT", owner);
        bridge = new CCIPNFTBridge(router, link, address(nft), owner);

        vm.prank(owner);
        nft.setBridge(address(bridge));
    }

    function testMintIsRestrictedToBridge() public {
        vm.expectRevert("Caller is not the bridge");
        nft.mint(receiver, 1, "ipfs://token-1");
    }

    function testBridgeCanMint() public {
        vm.prank(address(bridge));
        nft.mint(receiver, 1, "ipfs://token-1");

        assertEq(nft.ownerOf(1), receiver);
        assertEq(nft.tokenURI(1), "ipfs://token-1");
    }
}
