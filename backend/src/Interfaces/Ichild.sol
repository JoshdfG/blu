// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "../Interfaces/IFactory.sol";

interface ICHILD {
    struct lectureData {
        address mentorOnDuty;
        string topic;
        string uri;
        uint attendanceStartTime;
        uint studentsPresent;
        bool status;
    }

    function toggleOrganizationStatus() external;

    function getOrganizationStatus() external view returns (bool);

    function revoke(address[] calldata _individual) external;

    function liststudents() external view returns (address[] memory);

    // function VerifyStudent(address _student) external view returns (bool);

    function getStudentName(
        address _student
    ) external view returns (string memory name);

    function registerStaffs(Individual[] calldata staffList) external;

    function liststaff() external view returns (address[] memory);

    function VerifyStaffs(address _mentor) external view returns (bool);

    function getStaffsName(
        address _Mentor
    ) external view returns (string memory name);

    function createAttendance(
        bytes calldata _lectureId,
        string calldata _uri,
        string calldata _topic
    ) external;

    function getStaffsPresent(
        bytes memory _lectureId
    ) external view returns (uint);

    function getInactiveStaffs() external view returns (address[] memory);

    function getActiveStaffs() external view returns (address[] memory);

    function editStaffsName(Individual[] memory _mentorsList) external;

    function mentorHandover(address newMentor) external;

    function getMentorOnDuty() external view returns (address);

    function signAttendance(bytes calldata _lectureId) external;

    function openAttendance(bytes calldata _lectureId) external;

    function getNameArray(
        address[] calldata _students
    ) external view returns (string[] memory);

    function getStudentAttendanceRatio(
        address _student
    ) external view returns (uint attendace, uint TotalClasses);

    function listClassesAttended(
        address _student
    ) external view returns (uint[] memory);

    function getLectureData(
        bytes calldata _lectureId
    ) external view returns (lectureData memory);

    function EvictStudents(address[] calldata studentsToRevoke) external;

    function removeStaff(address[] calldata rouge_mentors) external;

    function reinstateStaff(address[] calldata staffToReinstate) external;

    function MintCertificate(string memory Uri) external;

    function mint_to_employee_of_the_month(
        string memory Uri,
        address staff
    ) external;

    function RequestNameCorrection() external;
}
