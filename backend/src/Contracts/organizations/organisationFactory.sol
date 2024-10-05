// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./organisation.sol";
import "../../Interfaces/ICERTFACTORY.sol";
import "../../Library/Errors/FactoryError/Error.sol";
import "../../Library/AppLib/FactoryLibrary.sol";

contract organisationFactory {
    FactoryLibrary.Layout internal f;

    constructor(address certFactory) {
        f.Admin = msg.sender;
        f.certificateFactory = certFactory;
    }

    function createorganisation(
        string memory _organisation,
        string memory _uri,
        string memory _symbol,
        string memory _adminName
    ) external returns (address Organisation, address Nft) {
        FactoryLibrary.createorganisation(
            _organisation,
            _uri,
            _symbol,
            _adminName,
            f
        );
    }

    function register(Individual[] calldata _individual) public {
        FactoryLibrary.register(_individual, f);
    }

    function revoke(address[] calldata _individual) public {
        FactoryLibrary.revoke(_individual, f);
    }

    function getOrganizations() public view returns (address[] memory) {
        return f.Organisations;
    }

    function getUserOrganisatons(
        address _userAddress
    ) public view returns (address[] memory) {
        return (f.memberOrganisations[_userAddress]);
    }
}
