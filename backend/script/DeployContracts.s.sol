// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "../src/Contracts/organizations/organisationFactory.sol";
import "../src/Contracts/certificates/certificateFactory.sol";
import "../src/Interfaces/Ichild.sol";

contract DeployContracts is Script {
    organisationFactory _organisationFactory;
    certificateFactory _certificateFactory;

    Individual student1;
    Individual[] students;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        _certificateFactory = new certificateFactory();
        _organisationFactory = new organisationFactory(
            address(_certificateFactory)
        );
        (address Organisation, address OrganisationNft, ) = _organisationFactory
            .createorganisation("WEB3BRIDGE", "http://test.org", "CHINONSO");

        vm.stopBroadcast();
        writeAddressesToFile(
            address(_organisationFactory),
            "Organisation Factory"
        );
        writeAddressesToFile(Organisation, "Organisation Address");
        writeAddressesToFile(OrganisationNft, "Organisation NFTAddress");
    }

    function writeAddressesToFile(address addr, string memory text) public {
        string memory filename = "./deployed_contracts2.txt";

        vm.writeLine(
            filename,
            "-------------------------------------------------"
        );
        vm.writeLine(filename, text);
        vm.writeLine(filename, vm.toString(addr));
        vm.writeLine(
            filename,
            "-------------------------------------------------"
        );
    }
}
