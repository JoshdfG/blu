// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../Interfaces/INFT.sol";
import "../../Interfaces/IFactory.sol";
import "../../Library/Errors/OrgError/Error.sol";
import "../../Library/AppLib/AppLibrary.sol";
import "../../Library/Events/OrgEvent/Event.sol";

contract organisation {
    AppLibrary.Layout internal l;

    bool public isOngoing = true;

    // @dev: constructor initialization
    // @params: _organization: Name of company,
    constructor(
        string memory _organization,
        address _org_owner,
        string memory _adminName,
        string memory _uri
    ) {
        l.org_owner = _org_owner;
        l.organization = _organization;
        l.organisationFactory = msg.sender;
        l.supervisor = _org_owner;
        l.indexInStaffsArray[_org_owner] = l.staffs.length;
        l.staffs.push(_org_owner);
        l.isStaff[_org_owner] = true;
        l.staffsData[_org_owner]._address = _org_owner;
        l.staffsData[_org_owner]._name = _adminName;
        l.organisationImageUri = _uri;
    }

    function initialize(address _NftContract) external {
        if (msg.sender != l.organisationFactory) {
            revert Error.not_Autorized_Caller();
        }
        l.NftContract = _NftContract;
    }

    function registerStaffs(Individual[] calldata staffList) external {
        AppLibrary.registerStaffs(staffList, l);
    }

    function TransferOwnership(address newModerator) external {
        AppLibrary.TransferOwnership(newModerator, l);
    }

    function RequestNameCorrection() external {
        AppLibrary.RequestNameCorrection(l);
    }

    function editStaffsName(Individual[] memory _staffList) external {
        AppLibrary.editStaffsName(_staffList, l);
    }

    function createNFT(bytes calldata id, string calldata _uri) external {
        AppLibrary.createNFT(id, _uri, l);
    }

    function mint_to_employee_of_the_month(
        bytes memory id,
        address _staff
    ) external {
        AppLibrary.mint_to_employee_of_the_month(id, _staff, l);
    }

    function createAttendance(
        bytes calldata _dayId,
        string calldata _uri,
        string calldata _topic
    ) external {
        AppLibrary.createAttendance(l, _dayId, _uri, _topic);
    }

    function openAttendance(bytes calldata _dayId) external {
        AppLibrary.openAttendance(_dayId, l);
    }

    function closeAttendance(bytes calldata _dayId) external {
        AppLibrary.closeAttendance(_dayId, l);
    }

    function signAttendance(bytes memory _daysId) external {
        AppLibrary.signAttendance(_daysId, l);
    }

    function getUserAttendanceRatio(
        address _user
    ) external view returns (uint attendance, uint TotalDaysAttendance) {
        AppLibrary.getUserAttendanceRatio(_user, l);
    }

    function mentorHandover(address newMentor) external {
        AppLibrary.mentorHandover(newMentor, l);
    }

    function removeStaff(address[] calldata rouge_staffs) external {
        AppLibrary.removeStaff(rouge_staffs, l);
    }

    function getNameArray(
        address[] calldata _staffs
    ) external view returns (string[] memory) {
        AppLibrary.getNameArray(_staffs, l);
    }

    function listAttendance(
        address _staffs
    ) external view returns (bytes[] memory) {
        if (l.isStaff[_staffs] == false) revert Error.NOT_STAFF();
        return l.dayAttended[_staffs];
    }

    function getDayIds() external view returns (bytes[] memory) {
        return l.dayIdCollection;
    }

    function getDaysData(
        bytes calldata _lectureId
    ) external view returns (AppLibrary.lectureData memory) {
        if (l.dayIdUsed[_lectureId] == false)
            revert Error.not_valid_lecture_id();
        return l.dayInstance[_lectureId];
    }

    function getStaffsPresent(
        bytes memory _daysId
    ) external view returns (uint) {
        return l.dayInstance[_daysId].usersPresent;
    }

    function getTasksGiven(
        address _moderator
    ) external view returns (bytes[] memory) {
        if (l.isStaff[_moderator] == false) revert Error.not_valid_Moderator();
        return l.moderatorsTopic[_moderator];
    }

    function getActiveStaffs() external view returns (address[] memory) {
        return l.activeStaff;
    }

    function getInactiveStaffs() external view returns (address[] memory) {
        return l.inactiveStaff;
    }

    function liststaff() external view returns (address[] memory) {
        return l.staffs;
    }

    function VerifyStaffs(address _mentor) external view returns (bool) {
        return l.isStaff[_mentor];
    }

    function getStaffsName(
        address _staff
    ) external view returns (string memory name) {
        if (l.isStaff[_staff] == false) revert Error.not_valid_Moderator();
        return l.staffsData[_staff]._name;
    }

    function getsupervisor() external view returns (address) {
        return l.supervisor;
    }

    function getModerator() external view returns (address) {
        return l.org_owner;
    }

    function getOrganizationName() external view returns (string memory) {
        return l.organization;
    }

    function getOrganisationImageUri() external view returns (string memory) {
        return l.organisationImageUri;
    }

    function toggleOrganizationStatus() external {
        isOngoing = !isOngoing;
    }

    function getOrganizationStatus() external view returns (bool) {
        return isOngoing;
    }
}
