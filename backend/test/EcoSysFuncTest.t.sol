// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Interfaces/Ichild.sol";
import "../src/Interfaces/IFactory.sol";
import "../src/Contracts/organizations/organisationFactory.sol";
import "../src/Contracts/certificates/certificateFactory.sol";

// import "../src/Contracts/SchoolsNFT.sol";

contract EcosystemTest is Test {
    organisationFactory _organisationFactory;
    certificateFactory _certificateFactory;

    Individual student1;
    Individual[] students;
    Individual[] editstudents;

    Individual mentor;
    Individual[] mentors;
    Individual[] editMentors;
    address[] studentsToEvict;
    address[] rogue_mentors;
    address[] nameCheck;
    address mentorAdd = 0xfd182E53C17BD167ABa87592C5ef6414D25bb9B4;
    address studentAdd = 0x13B109506Ab1b120C82D0d342c5E64401a5B6381;
    address director = 0xA771E1625DD4FAa2Ff0a41FA119Eb9644c9A46C8;
    address public organisationAddress;

    function setUp() public {
        vm.prank(director);
        _certificateFactory = new certificateFactory();
        _organisationFactory = new organisationFactory(
            address(_certificateFactory)
        );
        student1._address = address(studentAdd);
        student1._name = "JOHN DOE";
        students.push(student1);

        mentor._address = address(mentorAdd);
        mentor._name = "MR. ABIMS";
        mentors.push(mentor);
    }

    function testOrgCreation() public {
        vm.startPrank(director);
        (address Organisation, address OrganisationNft) = _organisationFactory
            .createorganisation(
                "Blu_management",
                "http://test.org",
                "",
                "Abims"
            );
        address child = _organisationFactory.getUserOrganisatons(director)[0];

        bool status = ICHILD(child).getOrganizationStatus();
        assertEq(status, true);
        organisationAddress = Organisation;
        vm.stopPrank();
        assertEq(Organisation, organisationAddress);
    }

    // function testStudentRegister() public {
    //     testCohortCreation();
    //     vm.startPrank(director);
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];

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
    //     nameCheck.push(mentorAdd);
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];
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

    //     vm.startPrank(director);

    //     ICHILD(child).editStudentName(editstudents);

    //     string memory newStudentName = ICHILD(child).getStudentName(studentAdd);

    //     console.log(newStudentName);

    //     assertEq("MUSAA", newStudentName);
    // }

    function testRegisterStaff() public {
        testOrgCreation();
        vm.startPrank(director);

        address child = _organisationFactory.getUserOrganisatons(director)[0];

        ICHILD(child).registerStaffs(mentors);
        address[] memory list_of_staffs = ICHILD(child).liststaff();

        bool mentorStatus = ICHILD(child).VerifyStaffs(mentorAdd);

        address[] memory active_staffs = ICHILD(child).getInactiveStaffs();

        string memory mentorName = ICHILD(child).getStaffsName(mentorAdd);

        assertEq(2, list_of_staffs.length);
        assertEq(true, mentorStatus);
        assertEq("MR. ABIMS", mentorName);
    }

    function testRemoveMentor() public {
        testRegisterStaff();
        vm.startPrank(director);
        rogue_mentors.push(mentorAdd);
        address child = _organisationFactory.getUserOrganisatons(director)[0];
        ICHILD(child).removeStaff(rogue_mentors);
        address[] memory inactive_staffs = ICHILD(child).getInactiveStaffs();

        assertEq(1, inactive_staffs.length);

        address[] memory mentorsList = ICHILD(child).liststaff();
        address[] memory mentorsOrganizations = _organisationFactory
            .getUserOrganisatons(mentorAdd);
        bool status = ICHILD(child).VerifyStaffs(mentorAdd);
        assertEq(0, mentorsOrganizations.length);
        assertEq(1, mentorsList.length);
        assertEq(false, status);
    }

    function testSignAttendance() public {
        testRegisterStaff();
        vm.startPrank(mentorAdd);
        uint256 currentTime = 1643723400;
        vm.warp(currentTime);

        address child = _organisationFactory.getUserOrganisatons(director)[0];
        vm.startPrank(mentorAdd);
        ICHILD(child).signAttendance();

        currentTime = 1643719800;
        vm.warp(currentTime);
    }

    // function testZ_edit_mentors_Name() public {
    //     testMentorRegister();
    //     vm.startPrank(mentorAdd);
    //     address child = _organisationFactory.getUserOrganisatons(mentorAdd)[0];

    //     ICHILD(child).RequestNameCorrection();

    //     vm.stopPrank();

    //     mentor._name = "Mr. Abimbola";
    //     mentor._address = mentorAdd;

    //     editMentors.push(mentor);

    //     vm.startPrank(director);

    //     ICHILD(child).editMentorsName(editMentors);

    //     string memory newMentorsName = ICHILD(child).getMentorsName(mentorAdd);

    //     console.log(newMentorsName);

    //     assertEq("Mr. Abimbola", newMentorsName);
    // }

    // function testCreateAttendance() public {
    //     testMentorHandOver();
    //     vm.startPrank(mentorAdd);
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];

    //     ICHILD(child).createAttendance(
    //         "B0202",
    //         "http://test.org",
    //         "INTRODUCTION TO BLOCKCHAIN"
    //     );

    //     vm.stopPrank();
    // }

    // function testGetStudentPresent() public {
    //     testCohortCreation();
    //     address child = organisationAddress;

    //     bytes memory lectureId = "B0202";
    //     testSignAttendance();
    //     uint studentsPresent = ICHILD(child).getStudentsPresent(lectureId);
    //     assertEq(studentsPresent, 1);
    // }

    // function testFail_TakeAttendaceBeforeClass() public {
    //     testCreateAttendance();
    //     vm.startPrank(studentAdd);
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];

    //     ICHILD(child).signAttendance("B0202");
    //     vm.stopPrank();
    // }

    // function testFail_StudentOpenAttendace() public {
    //     testCreateAttendance();
    //     vm.startPrank(studentAdd);
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];
    //     ICHILD(child).openAttendance("B0202");
    //     vm.stopPrank();
    // }

    // function testFail_StudentSignWrongAttendance() public {
    //     testCreateAttendance();
    //     vm.startPrank(mentorAdd);
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];
    //     ICHILD(child).openAttendance("B0202");
    //     vm.stopPrank();
    //     vm.startPrank(studentAdd);
    //     ICHILD(child).signAttendance("B0205");
    // }

    // function testSignAttendance() public {
    //     testCreateAttendance();
    //     vm.startPrank(mentorAdd);
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];
    //     ICHILD(child).openAttendance("B0202");
    //     vm.stopPrank();

    //     vm.startPrank(studentAdd);
    //     ICHILD(child).signAttendance("B0202");
    //     vm.stopPrank();
    // }

    // function testStudentsAttendanceData() public {
    //     testSignAttendance();
    //     vm.startPrank(mentorAdd);
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];
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
    //     assertEq(lectureData.mentorOnDuty, mentorAdd);
    //     assertEq(lectureData.uri, "http://test.org");
    //     assertEq(lectureData.attendanceStartTime, 1);
    //     assertEq(lectureData.studentsPresent, 1);
    //     assertEq(lectureData.status, true);
    // }

    // function testEvictStudent() public {
    //     testSignAttendance();
    //     vm.startPrank(director);
    //     studentsToEvict.push(studentAdd);
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];
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
    //     vm.startPrank(mentorAdd);
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];

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

    // function testCertificateIssuance() public {
    //     testSignAttendance();
    //     vm.startPrank(director);
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];
    //     ICHILD(child).MintCertificate("http://test.org");
    // }

    // function testMentorsSpok() public {
    //     testSignAttendance();
    //     vm.startPrank(director);
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];
    //     ICHILD(child).mintMentorsSpok("http://test.org");
    // }

    // function testToggleOrganizationStatus() public {
    //     testCohortCreation();
    //     address child = _organisationFactory.getUserOrganisatons(director)[0];

    //     ICHILD(child).toggleOrganizationStatus();

    //     // Now, the status should be false
    //     bool toggledStatus = ICHILD(child).getOrganizationStatus();
    //     assertEq(toggledStatus, false);

    //     // Toggle the status to true
    //     // ICHILD(child).toggleOrganizationStatus();

    //     bool finalStatus = ICHILD(child).getOrganizationStatus();
    //     assertEq(finalStatus, true);
    // }
}
