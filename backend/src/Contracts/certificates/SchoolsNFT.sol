// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../lib/openzeppelin-contracts.git/contracts/token/ERC1155/ERC1155.sol";
import "../../../lib/openzeppelin-contracts.git/contracts/access/Ownable.sol";

contract MyERC1155Token is ERC1155, Ownable {
    // Mapping to store token data
    mapping(uint256 => TokenData) public tokenData;

    // Mapping to store minting status
    mapping(bytes32 => bool) public mintingDisabled;

    // Event emitted when a new token is registered
    event newTokenRegistered(uint256 tokenId);

    // Event emitted when minting is disabled
    event mintingDisabled(bytes32 PassCode);

    // Event emitted when minting is successful
    event mintSuccesful(address user);

    // Struct to store token data
    struct TokenData {
        uint256 NftId;
        uint256 TotalMinted;
        bytes32 NftPasscode;
        uint256 dateCreated;
    }

    // Constructor
    constructor() ERC1155("") Ownable() {}

    // Function to register a new token
    function RegisterToken(string memory tokenPassCode) public onlyOwner {
        // Generate a new token ID
        uint256 newTokenId = totalNft() + 1;

        // Store token data
        tokenData[newTokenId] = TokenData(
            newTokenId,
            0,
            bytes32(keccak256(abi.encodePacked(tokenPassCode))),
            block.timestamp
        );

        // Emit event
        emit newTokenRegistered(newTokenId);
    }

    // Function to get all NFT data
    function allNftData(
        uint256 nftId
    )
        public
        view
        returns (
            uint256 NftId,
            uint256 TotalMinted,
            bytes32 NftPasscode,
            uint256 dateCreated
        )
    {
        return (
            tokenData[nftId].NftId,
            tokenData[nftId].TotalMinted,
            tokenData[nftId].NftPasscode,
            tokenData[nftId].dateCreated
        );
    }

    // Function to disable minting
    function disableMinting(string memory tokenPassCode) public onlyOwner {
        mintingDisabled[
            bytes32(keccak256(abi.encodePacked(tokenPassCode)))
        ] = true;
        emit mintingDisabled(
            bytes32(keccak256(abi.encodePacked(tokenPassCode)))
        );
    }

    // Function to check if minting is disabled
    function isDisabled(bytes32 nftPasscode) public view returns (bool) {
        return mintingDisabled[nftPasscode];
    }

    // Function to mint a token
    function mint(string memory NftPasscode) public {
        // Check if minting is disabled
        require(
            !isDisabled(bytes32(keccak256(abi.encodePacked(NftPasscode)))),
            "Minting is disabled"
        );

        // Get token ID
        uint256 tokenId = tokenData[
            bytes32(keccak256(abi.encodePacked(NftPasscode)))
        ].NftId;

        // Mint token
        _mint(msg.sender, tokenId, 1, "");

        // Increment total minted
        tokenData[tokenId].TotalMinted++;

        // Emit event
        emit mintSuccesful(msg.sender);
    }

    // Function to get total mints
    function totalMints(address user) public view returns (uint256) {
        return balanceOf(user, 1);
    }

    // Function to get total NFTs
    function totalNft() public view returns (uint256) {
        return ERC1155.totalSupply(1);
    }
}
