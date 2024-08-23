// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../lib/openzeppelin-contracts.git/contracts/token/ERC1155/ERC1155.sol";
import "../../../lib/openzeppelin-contracts.git/contracts/access/Ownable.sol";

contract employeeNFT is ERC1155, Ownable {
    string public name;
    string public symbol;
    address public admin;
    struct TokenData {
        uint256 NftId;
        uint256 TotalMinted;
        bytes32 NftPasscode;
        uint256 dateCreated;
    }
    TokenData[] public tokens;

    mapping(bytes32 => bool) public is_minting_Disabled;

    mapping(uint256 => TokenData) public tokenData;
    mapping(address => mapping(uint256 => uint256)) private _balances;

    event mintSuccesful(address user);
    event mintingDisabled(bytes32 PassCode);
    event newTokenRegistered(uint256 tokenId);

    constructor(
        address _admin,
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC1155(_uri) Ownable(_admin) {
        _admin = msg.sender;
        name = _name;
        symbol = _symbol;
        admin = _admin;
    }

    function RegisterToken(string memory tokenPassCode) public onlyOwner {
        bytes32 hashedPasscode = keccak256(abi.encodePacked(tokenPassCode));
        uint256 tokenId = uint256(hashedPasscode);

        require(tokenData[tokenId].NftId == 0, "Token already registered");
        TokenData memory newToken = TokenData({
            NftId: tokenId,
            TotalMinted: 0,
            NftPasscode: hashedPasscode,
            dateCreated: block.timestamp
        });

        tokenData[tokenId] = newToken;
        tokens.push(newToken);

        emit newTokenRegistered(tokenId);
    }

    function disableMinting(string memory tokenPassCode) public onlyOwner {
        bytes32 hashedPasscode = keccak256(abi.encodePacked(tokenPassCode));
        is_minting_Disabled[hashedPasscode] = true;
        emit mintingDisabled(hashedPasscode);
    }

    function mint(string memory NftPasscode) public {
        bytes32 hashedPasscode = keccak256(abi.encodePacked(NftPasscode));

        require(!is_minting_Disabled[hashedPasscode], "Minting is disabled");

        // Convert bytes32 to uint256 by casting directly
        uint256 tokenId = uint256(hashedPasscode);

        _mint(msg.sender, tokenId, 1, "");

        tokenData[uint256(hashedPasscode)].TotalMinted++;

        emit mintSuccesful(msg.sender);
    }

    function allNftData(
        uint256 nftId
    ) public view returns (uint256, uint256, bytes32, uint256) {
        TokenData memory data = tokenData[nftId];
        return (
            data.NftId,
            data.TotalMinted,
            data.NftPasscode,
            data.dateCreated
        );
    }

    function balanceOf(
        address account,
        uint256 id
    ) public view override returns (uint256) {
        return _balances[account][id];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) public view override returns (uint256[] memory) {
        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; i++) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function isDisabled(bytes32 nftPasscode) public view returns (bool) {
        return is_minting_Disabled[nftPasscode];
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override {
        require(operator != msg.sender, "ERC1155InvalidOperator");
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public override {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ERC1155MissingApprovalForAll"
        );
        _safeTransferFrom(from, to, id, value, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public override {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ERC1155MissingApprovalForAll"
        );
        _safeBatchTransferFrom(from, to, ids, values, data);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function uri(uint256 id) public view override returns (string memory) {
        return super.uri(id);
    }

    function totalNft() public view returns (uint256) {
        return tokens.length;
    }

    function totalMints(address user) public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < tokens.length; i++) {
            total += balanceOf(user, i);
        }
        return total;
    }
}
