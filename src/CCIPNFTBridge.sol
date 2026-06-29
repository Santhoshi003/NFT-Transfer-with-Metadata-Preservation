// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IRouterClient} from "./chainlink/interfaces/IRouterClient.sol";
import {Client} from "./chainlink/libraries/Client.sol";
import {CCIPReceiver} from "./chainlink/applications/CCIPReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./CrossChainNFT.sol";

contract CCIPNFTBridge is CCIPReceiver, IERC721Receiver, Ownable {
    CrossChainNFT public immutable nft;
    IRouterClient public router;
    IERC20 public linkToken;

    uint64 public constant DESTINATION_CHAIN_SELECTOR = 16015286601757825753; // Arbitrum Sepolia placeholder
    address public destinationBridge;
    uint64 public sourceChainSelector;
    address public sourceBridge;

    event NFTSent(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address indexed receiver,
        uint256 tokenId,
        string tokenURI
    );
    event NFTReceived(bytes32 indexed messageId, uint256 tokenId, address receiver);

    constructor(address _router, address _link, address _nft, address initialOwner)
        CCIPReceiver(_router)
        Ownable(initialOwner)
    {
        router = IRouterClient(_router);
        linkToken = IERC20(_link);
        nft = CrossChainNFT(_nft);
    }

    function setDestinationBridge(address _destinationBridge) external onlyOwner {
        destinationBridge = _destinationBridge;
    }

    function setSourceConfig(uint64 _sourceChainSelector, address _sourceBridge) external onlyOwner {
        sourceChainSelector = _sourceChainSelector;
        sourceBridge = _sourceBridge;
    }

    function sendNFT(uint64 destinationChainSelector, address receiver, uint256 tokenId)
        external
        returns (bytes32 messageId)
    {
        require(receiver != address(0), "receiver cannot be zero");
        require(nft.ownerOf(tokenId) == msg.sender, "caller is not owner");

        string memory tokenURI = nft.tokenURI(tokenId);
        nft.burn(tokenId);

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(destinationBridge),
            data: abi.encode(tokenId, receiver, tokenURI),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000, strict: false})
            ),
            feeToken: address(linkToken)
        });

        uint256 fee = router.getFee(destinationChainSelector, message);
        require(linkToken.transferFrom(msg.sender, address(this), fee), "failed transferFrom");
        require(linkToken.approve(address(router), fee), "failed approve");

        messageId = router.ccipSend(destinationChainSelector, message);
        emit NFTSent(messageId, destinationChainSelector, receiver, tokenId, tokenURI);
        return messageId;
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        require(message.sourceChainSelector == sourceChainSelector, "invalid source chain");
        require(abi.decode(message.sender, (address)) == sourceBridge, "invalid sender");

        (uint256 tokenId, address receiver, string memory tokenURI) = abi.decode(message.data, (uint256, address, string));
        if (nft.exists(tokenId)) {
            revert("token already exists");
        }

        nft.mint(receiver, tokenId, tokenURI);
        emit NFTReceived(message.messageId, tokenId, receiver);
    }

    function estimateTransferCost(uint64 destinationChainSelector) external view returns (uint256) {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(destinationBridge),
            data: abi.encode(uint256(0), address(0), ""),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000, strict: false})
            ),
            feeToken: address(linkToken)
        });
        return router.getFee(destinationChainSelector, message);
    }

    function onERC721Received(address, address, uint256, bytes calldata)
        external
        pure
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }
}
