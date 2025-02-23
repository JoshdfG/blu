// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "../Interfaces/IFactory.sol";

interface ICHILD {
    struct lectureData {
        address mentorOnDuty;
        string topic;
        string uri;
        uint attendanceStartTime;
        uint usersPresent;
        bool status;
    }

    function toggleOrganizationStatus() external;

    function getOrganizationStatus() external view returns (bool);

    function revoke(address[] calldata _individual) external;

    function liststudents() external view returns (address[] memory);

    function getDaysData(
        bytes calldata _lectureId
    ) external view returns (lectureData memory);

    function registerStaffs(Individual[] calldata staffList) external;

    function liststaff() external view returns (address[] memory);

    function VerifyStaffs(address _mentor) external view returns (bool);

    function getStaffsName(
        address _staff
    ) external view returns (string memory name);

    function createAttendance(
        bytes calldata _dayId,
        string calldata _uri,
        string calldata _topic
    ) external;

    function getStaffsPresent(
        bytes memory _daysId
    ) external view returns (uint);

    function getInactiveStaffs() external view returns (address[] memory);

    function getActiveStaffs() external view returns (address[] memory);

    function editStaffsName(Individual[] memory _mentorsList) external;

    function mentorHandover(address newMentor) external;

    function getMentorOnDuty() external view returns (address);

    function signAttendance(bytes memory _daysId) external;

    function openAttendance(bytes calldata _lectureId) external;

    function getNameArray(
        address[] calldata _students
    ) external view returns (string[] memory);

    function getUserAttendanceRatio(
        address _user
    ) external view returns (uint attendace, uint TotalClasses);

    function getAttendanceStatus(address student) external view returns (bool);

    function EvictStudents(address[] calldata studentsToRevoke) external;

    function removeStaff(address[] calldata rouge_mentors) external;

    function reinstateStaff(address[] calldata staffToReinstate) external;

    function MintCertificate(string memory Uri) external;

    function mint_to_employee_of_the_month(
        bytes memory id,
        address _staff
    ) external;

    function createNFT(bytes calldata id, string calldata _uri) external;

    function closeAttendance() external;

    function getAttendanceCount(
        address _student
    ) external view returns (uint256);

    function getDayIds() external view returns (bytes[] memory);

    function RequestNameCorrection() external;

    function listAttendance(
        address _student
    ) external view returns (bytes[] memory);
}
