// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../Interfaces/INFT.sol";
import "../../Interfaces/IFactory.sol";
import "../../Library/Error.sol";
import "../../Library/Storage.sol";

contract organisation {
    /**
     * ============================================================ *
     * --------------------- ORGANIZATION RECORD------------------- *
     * ============================================================ *
     */
    string organization;
    string cohort;
    string public certiificateURI;
    address organisationFactory;
    address public NftContract;
    address public certificateContract;
    bool public certificateIssued;
    string public organisationImageUri;
    bool public isOngoing = true;

    address public spokContract;
    string public spokURI;

    bool public spokMinted;
    mapping(address => bool) requestNameCorrection;

    /**
     * ============================================================ *
     * --------------------- STAFFS RECORD------------------------- *
     * ============================================================ *
     */
    address org_owner;
    address supervisor;
    address[] mentors;
    mapping(address => uint) indexInStaffsArray;
    mapping(address => bytes[]) moderatorsTopic;
    mapping(address => bool) isStaff;
    // mapping(address => bool) public isInactiveStaff;
    mapping(address => bool) public isActiveStaff;
    address[] public inactiveStaff;
    address[] public activeStaff;
    //tracking staff attendance
    mapping(address => Individual) staffsData;
    mapping(address => uint) indexInStudentsArray;
    mapping(address => uint) studentsTotalAttendance;
    mapping(address => bool[]) public attendanceRecord;

    mapping(address => bool) public IndividualAttendanceRecord;

    // MODIFIERS

    function onlyModerator() private view {
        if (msg.sender != org_owner) {
            revert Error.NOT_MODERATOR();
        }
    }

    modifier only_Staff_name_change() {
        require(
            msg.sender == org_owner || isStaff[msg.sender] == true,
            "NOT ALLOWED TO REQUEST A NAME CHANGE"
        );
        _;
    }

    function onlyStaff() private view {
        if (isStaff[msg.sender] == false) {
            revert Error.NOT_STAFF();
        }
    }

    // @dev: constructor initialization
    // @params: _organization: Name of company,
    constructor(
        string memory _organization,
        address _org_owner,
        string memory _adminName,
        string memory _uri
    ) {
        org_owner = _org_owner;
        organization = _organization;
        organisationFactory = msg.sender;
        supervisor = _org_owner;
        indexInStaffsArray[_org_owner] = mentors.length;
        mentors.push(_org_owner);
        isStaff[_org_owner] = true;
        staffsData[_org_owner]._address = _org_owner;
        staffsData[_org_owner]._name = _adminName;
        organisationImageUri = _uri;
    }

    function initialize(address _NftContract) external {
        if (msg.sender != organisationFactory)
            revert Error.not_Autorized_Caller();
        NftContract = _NftContract;
    }

    // @dev: Function to register staffs to be called only by the moderator
    // @params: staffList: An array of structs(individuals) consisting of name and wallet address of staffs.
    function registerStaffs(Individual[] calldata staffList) external {
        onlyModerator();
        uint staffLength = staffList.length;
        for (uint i; i < staffLength; i++) {
            if (isStaff[staffList[i]._address] == false) {
                staffsData[staffList[i]._address] = staffList[i];
                isStaff[staffList[i]._address] = true;
                indexInStaffsArray[staffList[i]._address] = mentors.length;
                isActiveStaff[staffList[i]._address] = true;
                activeStaff.push(staffList[i]._address);
                mentors.push(staffList[i]._address);
            }
        }
        IFACTORY(organisationFactory).register(staffList);
        emit Storage.staffsRegistered(staffList.length);
    }

    function TransferOwnership(address newModerator) external {
        onlyModerator();
        assert(newModerator != address(0));
        org_owner = newModerator;
    }

    // @dev: Function to request name correction
    function RequestNameCorrection() external only_Staff_name_change {
        if (requestNameCorrection[msg.sender] == true)
            revert Error.already_requested();
        requestNameCorrection[msg.sender] = true;
        emit Storage.nameChangeRequested(msg.sender);
    }

    function editStaffsName(
        Individual[] memory _mentorsList
    ) external only_Staff_name_change {
        uint staffsLength = _mentorsList.length;
        for (uint i; i < staffsLength; i++) {
            if (requestNameCorrection[_mentorsList[i]._address] == true) {
                staffsData[_mentorsList[i]._address] = _mentorsList[i];
                requestNameCorrection[_mentorsList[i]._address] = false;
            }
        }
        emit Storage.StaffNamesChanged(_mentorsList.length);
    }

    // @dev: Function to mint nft to employee of the month
    function mint_to_employee_of_the_month(
        string memory Uri,
        address staff
    ) external {
        onlyModerator();
        require(spokMinted == false, "spok already minted");
        require(spokContract != address(0), "spok contract not set");
        require(isStaff[staff] == true, "staff not found in mentors array");
        INFT(spokContract).mint(staff, Uri);
        spokURI = Uri;
        spokMinted = true;
    }

    function signAttendance() external {
        onlyStaff();
        // Check if the current time is within the allowed range (8am - 5pm)
        uint256 currentTime = block.timestamp;
        // 8am WAT
        uint256 startOfDay = currentTime - (currentTime % 86400) + 30600;
        // 5pm WAT
        uint256 endOfDay = startOfDay + 34200;

        if (currentTime < startOfDay || currentTime > endOfDay) {
            revert Error.outside_allowed_hours();
        }

        if (IndividualAttendanceRecord[msg.sender] == true) {
            revert Error.Already_Signed_Attendance();
        }

        IndividualAttendanceRecord[msg.sender] = true;
        studentsTotalAttendance[msg.sender] += 1;
        attendanceRecord[msg.sender].push(true);
        emit Storage.AttendanceSigned(msg.sender);
    }

    function closeAttendance() external {
        for (uint256 i = 0; i < mentors.length; i++) {
            address _student = mentors[i];
            IndividualAttendanceRecord[_student] = false;
        }
    }

    function getAttendanceStatus(address student) external view returns (bool) {
        return IndividualAttendanceRecord[student];
    }

    function removeStaff(address[] calldata rouge_staffs) external {
        onlyModerator();
        uint mentorsRouge = rouge_staffs.length;
        for (uint i; i < mentorsRouge; i++) {
            isStaff[rouge_staffs[i]] = false;
            isActiveStaff[rouge_staffs[i]] = false;

            // isInactiveStaff[rouge_staffs[i]] = true;
            inactiveStaff.push(rouge_staffs[i]);
        }
        IFACTORY(organisationFactory).revoke(rouge_staffs);
        emit Storage.staffsRemoved(rouge_staffs.length);
    }

    //VIEW FUNCTION

    function getStaffsPresent() external view returns (bool[] memory) {
        return attendanceRecord[msg.sender];
    }

    function getActiveStaffs() external view returns (address[] memory) {
        return activeStaff;
    }

    function getInactiveStaffs() external view returns (address[] memory) {
        return inactiveStaff;
    }

    function listMentors() external view returns (address[] memory) {
        return mentors;
    }

    function VerifyMentor(address _mentor) external view returns (bool) {
        return isStaff[_mentor];
    }

    function getStaffsName(
        address _Mentor
    ) external view returns (string memory name) {
        if (isStaff[_Mentor] == false) revert Error.not_valid_Moderator();
        return staffsData[_Mentor]._name;
    }

    function getsupervisor() external view returns (address) {
        return supervisor;
    }

    function getModerator() external view returns (address) {
        return org_owner;
    }

    function getOrganizationName() external view returns (string memory) {
        return organization;
    }

    function getCohortName() external view returns (string memory) {
        return cohort;
    }

    function getOrganisationImageUri() external view returns (string memory) {
        return organisationImageUri;
    }

    function toggleOrganizationStatus() external {
        isOngoing = !isOngoing;
    }

    function getOrganizationStatus() external view returns (bool) {
        return isOngoing;
    }
}
