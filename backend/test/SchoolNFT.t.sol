// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Contracts/certificates/SchoolsNFT.sol";

contract SchoolsNFTTest is Test {
    //     SchoolsNFT schoolsNFT;
    //     function setUp() public {
    //         schoolsNFT = new SchoolsNFT(
    //             "Test School",
    //             "TS",
    //             "ipfs://example.com/",
    //             address(this)
    //         );
    //     }
    //     function testMintAndMintSpokToMentor() public {
    //         // Mint a token for a test address
    //         address testAddress = address(0x123);
    //         bytes memory dayId = "testDay";
    //         uint256 amount = 1;
    //         schoolsNFT.setDayUri(dayId, "https://example.com/test.png");
    //         schoolsNFT.mint(testAddress, dayId, amount);
    //         assertEq(
    //             schoolsNFT.balanceOf(testAddress),
    //             amount,
    //             "Balance should match"
    //         );
    //         // Mint a SPOK token to another test address
    //         address mentorAddress = address(0x456);
    //         schoolsNFT.mintSpokToMentor(mentorAddress);
    //         assertEq(
    //             schoolsNFT.balanceOf(mentorAddress),
    //             1,
    //             "Balance should match"
    //         );
    //     }
}

// import "forge-std/Test.sol";
// import "../src/Contracts/SchoolsNFT.sol";

// contract SchoolsNFTTest is Test {
//     SchoolsNFT _schoolsNFT;
//     address[] _students = [address(1), address(2), address(3)];
//     uint256[] _amounts = [1, 1, 1];

//     address _admin = address(123);

//     function setUp() public {
//         _schoolsNFT = new SchoolsNFT("Test", "TST", "http://test.org", _admin);
//     }

//     function testName() public {
//         string memory _name = _schoolsNFT.name();
//         assertEq(_name, "Test");
//     }

//     function testUri() public {
//         string memory _uri = _schoolsNFT.uri(1);
//         assertEq(_uri, "http://test.org");
//     }

//     function testAdmin() public {
//         address admin = _schoolsNFT.admin();
//         assertEq(_admin, admin);
//     }

//     function testMint() public {
//         vm.prank(address(_admin));
//         _schoolsNFT.createClass(abi.encodePacked("test_class_id"), "http://test.org/1");
//         _schoolsNFT.getTokenIdForClass(abi.encodePacked("test_class_id"));
//         vm.prank(address(_admin));
//         _schoolsNFT.mint(address(1), abi.encodePacked("test_class_id"), 1);
//         uint256 userBalance = _schoolsNFT.balanceOf(address(1), 1);
//         assertEq(userBalance, 1);
//     }

//     function testBatchMintNFTForClass() public {
//         vm.prank(address(_admin));
//         _schoolsNFT.createClass(abi.encodePacked("test_class_id"), "http://test.org/1");
//         vm.prank(address(_admin));
//         _schoolsNFT.batchMintNFTForClass(abi.encodePacked("test_class_id"), _students, _amounts);
//         uint256 _bal = _schoolsNFT.balanceOf(address(3), 1);
//         assertEq(_bal, 1);
//     }

//     function testChangeClassUri() public {
//         testMint();
//         vm.prank(address(_admin));
//         _schoolsNFT.changeClassUri(abi.encodePacked("test_class_id"), "http://test.org/1");
//         string memory _uri = _schoolsNFT.getClassUri(abi.encodePacked("test_class_id"));
//         assertEq(_uri, "http://test.org/1");
//     }
// }
