// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Interfaces/Ichild.sol";
import "../src/Interfaces/IFactory.sol";
import "../src/Contracts/organizations/organisationFactory.sol";
import "../src/Contracts/certificates/certificateFactory.sol";
import "../src/Library/Error.sol";

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

    // function testStudentRegister() public {
    //     testCohortCreation();
    //     vm.startPrank(org_owner);
    //     address child = _organisationFactory.getUserOrganisatons(org_owner)[0];

    //     ICHILD(child).registerStudents(students);
    //     address[] memory studentsList = ICHILD(child).liststudents();
    //     bool studentStatus = ICHILD(child).VerifyStudent(studentAdd);
    //     string memory studentName = ICHILD(child).getStudentName(studentAdd);
    //     assertEq(1, studentsList.length);
    //     assertEq(true, studentStatus);
    //     assertEq("JOHN DOE", studentName);
    //     vm.stopPrank();
    // }

    // function testGetStudentsNamesArray() public {
    //     testStudentRegister();
    //     nameCheck.push(studentAdd);
    //     nameCheck.push(staff_Add);
    //     address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
    //     string[] memory studentsName = ICHILD(child).getNameArray(nameCheck);
    //     assertEq(studentsName[0], "JOHN DOE");
    //     assertEq(studentsName[1], "UNREGISTERED");
    //     console.log(studentsName[0]);
    //     console.log(studentsName[1]);
    // }

    // function testZ_edit_students_Name() public {
    //     testStudentRegister();
    //     vm.startPrank(studentAdd);
    //     address child = _organisationFactory.getUserOrganisatons(studentAdd)[0];

    //     ICHILD(child).RequestNameCorrection();

    //     vm.stopPrank();

    //     student1._name = "MUSAA";
    //     student1._address = studentAdd;
    //     editstudents.push(student1);

    //     vm.startPrank(org_owner);

    //     ICHILD(child).editStudentName(editstudents);

    //     string memory newStudentName = ICHILD(child).getStudentName(studentAdd);

    //     console.log(newStudentName);

    //     assertEq("MUSAA", newStudentName);
    // }

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

    function testSignAttendance() public {
        testRegisterStaff();
        vm.startPrank(staff_Add);
        uint256 currentTime = 1643723400;
        vm.warp(currentTime);

        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
        vm.startPrank(staff_Add);
        ICHILD(child).signAttendance();

        currentTime = 1643719800;
        vm.warp(currentTime);
    }

    // function testZ_edit_mentors_Name() public {
    //     testMentorRegister();
    //     vm.startPrank(staff_Add);
    //     address child = _organisationFactory.getUserOrganisatons(staff_Add)[0];

    //     ICHILD(child).RequestNameCorrection();

    //     vm.stopPrank();

    //     mentor._name = "Mr. Abimbola";
    //     mentor._address = staff_Add;

    //     editStaffs.push(mentor);

    //     vm.startPrank(org_owner);

    //     ICHILD(child).editStaffsName(editStaffs);

    //     string memory newMentorsName = ICHILD(child).getMentorsName(staff_Add);

    //     console.log(newMentorsName);

    //     assertEq("Mr. Abimbola", newMentorsName);
    // }

    function testGetPresentStaffs() public {
        testOrgCreation();
        address child = organisationAddress;

        testSignAttendance();
        bool[] memory present_staffs = ICHILD(child).getStaffsPresent();
        assertEq(true, present_staffs.length > 0);
    }

    function testFail_SignMultipleAttendance() public {
        testSignAttendance();
        vm.startPrank(staff_Add);
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];

        ICHILD(child).signAttendance();

        vm.stopPrank();
    }

    function testGetAttendanceStatus() public {
        testSignAttendance();
        vm.startPrank(staff_Add);
        address child = _organisationFactory.getUserOrganisatons(org_owner)[0];

        ICHILD(child).getAttendanceStatus(staff_Add);
    }

    // function testStudentsAttendanceData() public {
    //     testSignAttendance();
    //     vm.startPrank(staff_Add);
    //     address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
    //     (uint attendace, uint totalClasses) = ICHILD(child)
    //         .getStudentAttendanceRatio(studentAdd);

    //     uint[] memory lectures = ICHILD(child).getLectureIds();
    //     ICHILD.lectureData memory lectureData = ICHILD(child).getLectureData(
    //         "B0202"
    //     );

    //     assertEq(attendace, totalClasses);
    //     assertEq(lectures.length, 1);
    //     // assertEq(lectures[0], "B0202");
    //     assertEq(lectureData.topic, "INTRODUCTION TO BLOCKCHAIN");
    //     assertEq(lectureData.mentorOnDuty, staff_Add);
    //     assertEq(lectureData.uri, "http://test.org");
    //     assertEq(lectureData.attendanceStartTime, 1);
    //     assertEq(lectureData.studentsPresent, 1);
    //     assertEq(lectureData.status, true);
    // }

    // function testEvictStudent() public {
    //     testSignAttendance();
    //     vm.startPrank(org_owner);
    //     studentsToEvict.push(studentAdd);
    //     address child = _organisationFactory.getUserOrganisatons(org_owner)[0];
    //     ICHILD(child).EvictStudents(studentsToEvict);

    //     address[] memory studentsList = ICHILD(child).liststudents();
    //     address[] memory studentOrganizations = _organisationFactory
    //         .getUserOrganisatons(studentAdd);
    //     bool studentStatus = ICHILD(child).VerifyStudent(studentAdd);
    //     assertEq(0, studentOrganizations.length);
    //     assertEq(0, studentsList.length);
    //     assertEq(false, studentStatus);
    // }

    // function testFail_EvictedStudentSignAttendance() public {
    //     testEvictStudent();
    //     vm.startPrank(staff_Add);
    //     address child = _organisationFactory.getUserOrganisatons(org_owner)[0];

    //     ICHILD(child).createAttendance(
    //         "B0202",
    //         "http://test.org",
    //         "BLOCKCHAIN TRILEMA"
    //     );
    //     ICHILD(child).openAttendance("B0202");
    //     vm.stopPrank();

    //     vm.startPrank(studentAdd);
    //     ICHILD(child).signAttendance("B0202");
    //     vm.stopPrank();
    // }

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
