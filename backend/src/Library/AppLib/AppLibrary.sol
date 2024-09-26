// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "../../Library/Errors/OrgError/Error.sol";
import "../../Interfaces/IFactory.sol";
import "../../Interfaces/INFT.sol";
import "../../Library/Events/OrgEvent/Event.sol";

library AppLibrary {
    struct Layout {
        bytes[] dayIdCollection;
        mapping(bytes => lectureData) dayInstance;
        mapping(bytes => bool) dayIdUsed;
        mapping(address => bytes[]) dayOfTheWeek;
        //  organization record
        string organization;
        string certiificateURI;
        address organisationFactory;
        address NftContract;
        address certificateContract;
        bool certificateIssued;
        string organisationImageUri;
        string nftURI;
        bool has_minted;
        mapping(address => bool) requestNameCorrection;
        // staffs record
        address org_owner;
        address supervisor;
        address[] staffs;
        mapping(address => uint256) indexInStaffsArray;
        mapping(address => bytes[]) moderatorsTopic;
        mapping(address => bool) isStaff;
        mapping(address => bool) isActiveStaff;
        mapping(address => bool) notActive;
        address[] inactiveStaff;
        address[] activeStaff;
        //tracking staff attendance
        mapping(address => Individual) staffsData;
        mapping(address => uint256) indexInStudentsArray;
        mapping(address => bytes[]) dayAttended;
        mapping(address => uint256) staffsTotalAttendance;
        mapping(address => bool[]) attendanceRecord;
        // mapping(address => bool) IndividualAttendanceRecord;
        mapping(address => mapping(bytes => bool)) IndividualAttendanceRecord;
    }

    struct lectureData {
        address mentorOnDuty;
        string topic;
        string uri;
        uint attendanceStartTime;
        uint usersPresent;
        bool status;
    }

    function onlyModerator(Layout storage l) private view {
        if (msg.sender != l.org_owner) {
            revert Error.NOT_MODERATOR();
        }
    }

    function only_Staff_name_change(Layout storage l) private view {
        if (msg.sender != l.org_owner && l.isStaff[msg.sender] == false) {
            revert Error.NOT_STAFF();
        }
    }

    function onlyStaff(Layout storage l) private view {
        if (l.isStaff[msg.sender] == false) {
            revert Error.NOT_STAFF();
        }
    }

    // @dev: Function to register staffs to be called only by the organization owner
    // @params: staffList: An array of structs(individuals) consisting of name and wallet address of staffs.
    function registerStaffs(
        Individual[] calldata staffList,
        Layout storage l
    ) external {
        onlyModerator(l);

        uint256 staffLength = staffList.length;

        for (uint256 i; i < staffLength; i++) {
            if (l.isStaff[staffList[i]._address] == false) {
                l.staffsData[staffList[i]._address] = staffList[i];

                l.isStaff[staffList[i]._address] = true;

                l.indexInStaffsArray[staffList[i]._address] = l.staffs.length;

                l.isActiveStaff[staffList[i]._address] = true;

                l.activeStaff.push(staffList[i]._address);

                l.staffs.push(staffList[i]._address);
            }
        }
        IFACTORY(l.organisationFactory).register(staffList);

        emit Event.staffsRegistered(staffList.length);
    }

    function getNameArray(
        address[] calldata _students,
        Layout storage l
    ) external view returns (string[] memory) {
        string[] memory Names = new string[](_students.length);

        string memory emptyName;

        for (uint i = 0; i < _students.length; i++) {
            if (
                keccak256(abi.encodePacked(l.staffsData[_students[i]]._name)) ==
                keccak256(abi.encodePacked(emptyName))
            ) {
                Names[i] = "UNREGISTERED";
            } else {
                Names[i] = l.staffsData[_students[i]]._name;
            }
        }
        return Names;
    }

    function removeStaff(
        address[] calldata rouge_staffs,
        AppLibrary.Layout storage l
    ) external {
        onlyModerator(l);

        uint256 staffRouge = rouge_staffs.length;

        for (uint256 i; i < staffRouge; i++) {
            delete l.staffsData[rouge_staffs[i]];

            l.isStaff[rouge_staffs[i]] = false;

            l.isActiveStaff[rouge_staffs[i]] = false;

            l.staffs[l.indexInStaffsArray[rouge_staffs[i]]] = l.staffs[
                l.staffs.length - 1
            ];

            l.inactiveStaff.push(rouge_staffs[i]);

            l.notActive[rouge_staffs[i]] = true;

            l.staffs.pop();

            IFACTORY(l.organisationFactory).revoke(rouge_staffs);

            emit Event.staffsRemoved(rouge_staffs.length);
        }
    }

    function mentorHandover(address newMentor, Layout storage l) external {
        if (msg.sender != l.supervisor && msg.sender != l.org_owner)
            revert Error.not_Autorized_Caller();
        l.supervisor = newMentor;
        emit Event.Handover(msg.sender, newMentor);
    }

    function createAttendance(
        Layout storage l,
        bytes calldata _dayId,
        string calldata _uri,
        string calldata _topic
    ) external {
        if (l.dayIdUsed[_dayId] == true) revert Error.day_id_already_used();

        l.dayIdUsed[_dayId] = true;

        l.dayIdCollection.push(_dayId);

        l.dayInstance[_dayId].uri = _uri;

        l.dayInstance[_dayId].topic = _topic;

        l.dayInstance[_dayId].mentorOnDuty = msg.sender;

        l.dayOfTheWeek[msg.sender].push(_dayId);

        l.moderatorsTopic[msg.sender].push(_dayId);

        INFT(l.NftContract).setDayUri(_dayId, _uri);

        emit Event.attendanceCreated(_dayId, _uri, _topic, msg.sender);
    }

    function openAttendance(bytes calldata _dayId, Layout storage l) external {
        onlyModerator(l);

        if (l.dayIdUsed[_dayId] == false) revert Error.Invalid_Campaign_Id();

        if (l.dayInstance[_dayId].status == true)
            revert("Attendance already open");

        if (msg.sender != l.dayInstance[_dayId].mentorOnDuty)
            revert Error.not_Autorized_Caller();

        l.dayInstance[_dayId].status = true;

        emit Event.attendanceOpened(_dayId, msg.sender);
    }

    function closeAttendance(bytes calldata _dayId, Layout storage l) external {
        onlyModerator(l);

        if (l.dayIdUsed[_dayId] == false) revert Error.Invalid_Campaign_Id();

        if (l.dayInstance[_dayId].status == false)
            revert("Attendance already closed");

        if (msg.sender != l.dayInstance[_dayId].mentorOnDuty)
            revert Error.not_Autorized_Caller();

        l.dayInstance[_dayId].status = false;

        emit Event.attendanceClosed(_dayId, msg.sender);
    }

    function signAttendance(bytes memory _daysId, Layout storage l) external {
        onlyStaff(l);

        if (l.dayIdUsed[_daysId] == false) revert Error.Invalid_Campaign_Id();

        if (l.notActive[msg.sender] == true) {
            revert Error.NOT_ACTIVE_STAFF();
        }

        if (l.dayInstance[_daysId].status == false)
            revert Error.day_id_closed();

        if (l.IndividualAttendanceRecord[msg.sender][_daysId] == true)
            revert Error.Already_Signed_Attendance_For_Id();

        if (l.dayInstance[_daysId].attendanceStartTime == 0) {
            l.dayInstance[_daysId].attendanceStartTime = block.timestamp;
        }

        l.IndividualAttendanceRecord[msg.sender][_daysId] = true;

        l.staffsTotalAttendance[msg.sender] =
            l.staffsTotalAttendance[msg.sender] +
            1;

        l.dayInstance[_daysId].usersPresent =
            l.dayInstance[_daysId].usersPresent +
            1;

        l.dayAttended[msg.sender].push(_daysId);

        INFT(l.NftContract).mint(msg.sender, _daysId, 1);

        emit Event.AttendanceSigned(_daysId, msg.sender);
    }

    // @dev: Function to mint nft to employee of the month
    function createNFT(
        bytes calldata id,
        string calldata _uri,
        Layout storage l
    ) external {
        onlyModerator(l);

        INFT(l.NftContract).setDayUri(id, _uri);

        emit Event.nftCreated(id, _uri, msg.sender);
    }

    function mint_to_employee_of_the_month(
        bytes memory id,
        address _staff,
        Layout storage l
    ) external {
        onlyModerator(l);

        require(l.has_minted == false, "nft already minted");

        INFT(l.NftContract).mint(_staff, id, 1);

        l.has_minted = true;
    }

    function TransferOwnership(
        address newModerator,
        Layout storage l
    ) external {
        onlyModerator(l);

        assert(newModerator != address(0));

        l.org_owner = newModerator;
    }

    function RequestNameCorrection(Layout storage l) external {
        only_Staff_name_change(l);

        if (l.requestNameCorrection[msg.sender] == true) {
            revert Error.already_requested();
        }

        l.requestNameCorrection[msg.sender] = true;

        emit Event.nameChangeRequested(msg.sender);
    }

    function editStaffsName(
        Individual[] memory _staffList,
        Layout storage l
    ) external {
        only_Staff_name_change(l);

        uint256 staffsLength = _staffList.length;

        for (uint256 i; i < staffsLength; i++) {
            if (l.requestNameCorrection[_staffList[i]._address] == true) {
                l.staffsData[_staffList[i]._address] = _staffList[i];

                l.requestNameCorrection[_staffList[i]._address] = false;
            }
        }
        emit Event.StaffNamesChanged(_staffList.length);
    }

    // view functions
    function getUserAttendanceRatio(
        address _user,
        Layout storage l
    ) external view returns (uint attendance, uint TotalCampaign) {
        if (l.isStaff[_user] == false) revert Error.NOT_STAFF();

        attendance = l.staffsTotalAttendance[_user];

        TotalCampaign = l.dayIdCollection.length;
    }
}
