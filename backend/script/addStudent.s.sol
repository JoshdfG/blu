// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import "../src/Contracts/organizations/organisationFactory.sol";
import "../src/Contracts/certificates/certificateFactory.sol";
import "../src/Interfaces/Ichild.sol";

contract addStudent is Script {
    organisationFactory _organisationFactory;
    certificateFactory _certificateFactory;
    address child = address(0xE67D3ceb8e2B07A0524E02c25F725CF85c94Cd82);
    individual student1;
    individual[] students;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // uint256 deployerPrivateKey2 = vm.envUint("PRIVATE_KEY2");
        vm.startBroadcast(deployerPrivateKey);
        student1._address = address(0x7379ec8392c7684cecd0550A688D729717EBBB01);
        student1._name = "SAMUEL";
        students.push(student1);
        ICHILD(child).registerStudents(students);

        vm.stopBroadcast();
    }

    function writeAddressesToFile(address addr, string memory text) public {
        string memory filename = "./deployed_contracts.txt";

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
