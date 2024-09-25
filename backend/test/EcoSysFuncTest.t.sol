// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import "../src/Interfaces/Ichild.sol";
import "../src/Interfaces/IFactory.sol";
import "../src/Contracts/organizations/organisationFactory.sol";
import "../src/Contracts/certificates/certificateFactory.sol";
import "../src/Library/Errors/OrgError/Error.sol";

// import "../src/Contracts/SchoolsNFT.sol";

contract EcosystemTest is Test {
    organisationFactory _organisationFactory;
    certificateFactory _certificateFactory;

    Individual staff;
    Individual[] staffs;
    Individual[] editStaffs;
    address[] rogue_staffs;
    address[] nameCheck;

    address staff_Add = 0xfd182E53C17BD167ABa87592C5ef6414D25bb9B4;
    address org_owner = 0xA771E1625DD4FAa2Ff0a41FA119Eb9644c9A46C8;
    address public organisationAddress;

    function setUp() public {
        vm.prank(org_owner);
        _certificateFactory = new certificateFactory();
        _organisationFactory = new organisationFactory(
            address(_certificateFactory)
        );

        staff._address = address(staff_Add);
        staff._name = "MR. ABIMS";
        staffs.push(staff);
    }

    function testOrgCreation() public {
        vm.startPrank(org_owner);
        (address Organisation, address OrganisationNft) = _organisationFactory
            .createorganisation(
                "Blu_management",
                "http://test.org",
                "",
                "Abims"
            );
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];

        bool status = ICHILD(child).getOrganizationStatus();
        assertEq(status, true);
        organisationAddress = Organisation;
        vm.stopPrank();
        assertEq(Organisation, organisationAddress);
    }

    function testRegisterStaff() public {
        testOrgCreation();
        vm.startPrank(org_owner);

        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];

        ICHILD(child).registerStaffs(staffs);
        address[] memory list_of_staffs = ICHILD(child).liststaff();

        bool staff_stat = ICHILD(child).VerifyStaffs(staff_Add);

        address[] memory active_staffs = ICHILD(child).getInactiveStaffs();

        string memory mentorName = ICHILD(child).getStaffsName(staff_Add);

        assertEq(2, list_of_staffs.length);
        assertEq(true, staff_stat);
        assertEq("MR. ABIMS", mentorName);
    }

    function testRemoveMentor() public {
        testRegisterStaff();
        vm.startPrank(org_owner);
        rogue_staffs.push(staff_Add);
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
        ICHILD(child).removeStaff(rogue_staffs);
        address[] memory inactive_staffs = ICHILD(child).getInactiveStaffs();

        assertEq(1, inactive_staffs.length);

        address[] memory staff_list = ICHILD(child).liststaff();
        address[] memory staff_org = _organisationFactory.getUserOrganisatons(
            staff_Add
        );
        bool status = ICHILD(child).VerifyStaffs(staff_Add);
        assertEq(0, staff_org.length);
        assertEq(1, staff_list.length);
        assertEq(false, status);
    }

    function testCreateAttendance() public {
        // testMentorHandOver();
        testOrgCreation();
        vm.startPrank(org_owner);
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];

        ICHILD(child).createAttendance(
            "B0202",
            "http://test.org",
            "INTRODUCTION TO BLOCKCHAIN"
        );

        vm.stopPrank();
    }

    function testSignAttendance() public {
        testCreateAttendance();
        testRegisterStaff();
        vm.startPrank(org_owner);
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
        ICHILD(child).openAttendance("B0202");
        vm.stopPrank();

        vm.startPrank(staff_Add);
        ICHILD(child).signAttendance("B0202");
        vm.stopPrank();
    }

    function testStudentsAttendanceData() public {
        testSignAttendance();
        vm.startPrank(staff_Add);
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
        (uint attendace, uint totalClasses) = ICHILD(child)
            .getUserAttendanceRatio(staff_Add);

        bytes[] memory lectures = ICHILD(child).getDayIds();
        ICHILD.lectureData memory lectureData = ICHILD(child).getDaysData(
            "B0202"
        );

        assertEq(attendace, totalClasses);
        assertEq(lectures.length, 1);
        // assertEq(lectures[0], "B0202");
        assertEq(lectureData.mentorOnDuty, org_owner);
        assertEq(lectureData.uri, "http://test.org");
        assertEq(lectureData.attendanceStartTime, 1);
        assertEq(lectureData.usersPresent, 1);
        assertEq(lectureData.status, true);
    }

    function testGetStaffsPresent() public {
        testOrgCreation();
        address child = organisationAddress;
        bytes memory lectureId = "B0202";
        testSignAttendance();
        uint studentsPresent = ICHILD(child).getStaffsPresent(lectureId);
        assertEq(studentsPresent, 1);
    }

    function testFail_RogueStaffSignAttendance() public {
        testRemoveMentor();
        vm.startPrank(staff_Add);
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
        testSignAttendance();
    }

    // function testGetAttendanceStatus() public {
    //     testSignAttendance();
    //     vm.startPrank(staff_Add);
    //     address child = _organisationFactory.getUserOrganisatons(org_owner)[0];

    //     ICHILD(child).getAttendanceStatus(staff_Add);
    // }

    // function testCloseAttendance() public {
    //     testSignAttendance();
    //     vm.startPrank(org_owner);
    //     address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
    //     ICHILD(child).closeAttendance();
    //     ICHILD(child).getAttendanceStatus(staff_Add);
    // }

    // function testGetAttendanceCount() public {
    //     testSignAttendance();
    //     vm.startPrank(staff_Add);
    //     address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
    //     ICHILD(child).getAttendanceCount(staff_Add);
    //     assertEq(1, ICHILD(child).getAttendanceCount(staff_Add));
    // }

    function testListStaff() public {
        testRegisterStaff();
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
        address[] memory list_of_staffs = ICHILD(child).liststaff();
        assertEq(2, list_of_staffs.length);
    }

    function testGetInActiveStaff() public {
        testRemoveMentor();
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
        address[] memory active_staffs = ICHILD(child).getInactiveStaffs();
        assertEq(1, active_staffs.length);
    }

    function testGetActiveStaffs() public {
        testRegisterStaff();
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
        address[] memory active_staffs = ICHILD(child).getActiveStaffs();
        assertEq(1, active_staffs.length);
    }

    function testGetStaffsName() public {
        testRegisterStaff();
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
        string memory mentorName = ICHILD(child).getStaffsName(staff_Add);
        assertEq("MR. ABIMS", mentorName);
    }

    function testCreateNFT() public {
        testOrgCreation();
        vm.startPrank(org_owner);
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
        ICHILD(child).createNFT("B0202", "http://test.org");
    }

    function test_mint_to_employee_of_the_month() public {
        testOrgCreation();
        testRegisterStaff();
        vm.startPrank(org_owner);
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
        ICHILD(child).mint_to_employee_of_the_month(
            "http://test.org",
            staff_Add
        );
    }

    function testToggleOrganizationStatus() public {
        testOrgCreation();
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];

        ICHILD(child).toggleOrganizationStatus();

        bool toggledStatus = ICHILD(child).getOrganizationStatus();
        assertEq(toggledStatus, false);
    }
}
