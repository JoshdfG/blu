// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface INFT {
    // function mint(address _to, string memory _uri) external;
    // function mint(string memory NftPasscode) external;
    function mint(
        address _to,
        bytes calldata _daysId,
        uint256 _amount
    ) external;

    function _mint(
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) external;

    function setDayUri(bytes calldata id, string memory _uri) external;

    function batchMintTokens(
        address[] memory users,
        string memory uri
    ) external;
}
