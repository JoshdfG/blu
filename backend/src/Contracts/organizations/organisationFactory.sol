// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./organisation.sol";
import "../../Interfaces/ICERTFACTORY.sol";

contract organisationFactory {
    address public Admin;
    address organisationAdmin;
    address certificateFactory;
    address[] public Organisations;
    mapping(address => bool) public validOrganisation;

    mapping(address => mapping(address => uint))
        public studentOrganisationIndex;
    mapping(address => address[]) public memberOrganisations;
    mapping(address => bool) public uniqueStudent;
    uint public totalUsers;

    constructor(address certFactory) {
        Admin = msg.sender;
        certificateFactory = certFactory;
    }

    function createorganisation(
        string memory _organisation,
        string memory _uri,
        string memory _adminName
    ) external returns (address Organisation, address Nft) {
        organisationAdmin = msg.sender;
        organisation OrganisationAddress = new organisation(
            _organisation,
            organisationAdmin,
            _adminName,
            _uri
        );
        Organisations.push(address(OrganisationAddress));
        validOrganisation[address(OrganisationAddress)] = true;
        address AttendanceAddr = ICERTFACTORY(certificateFactory)
            .completePackage(_organisation, _uri, address(OrganisationAddress));

        OrganisationAddress.initialize(address(AttendanceAddr));
        uint orgLength = memberOrganisations[msg.sender].length;
        studentOrganisationIndex[msg.sender][
            address(OrganisationAddress)
        ] = orgLength;
        memberOrganisations[msg.sender].push(address(OrganisationAddress));

        Nft = address(AttendanceAddr);
        Organisation = address(OrganisationAddress);
    }

    function register(Individual[] calldata _individual) public {
        require(
            validOrganisation[msg.sender] == true,
            "unauthorized Operation"
        );
        uint individualLength = _individual.length;
        for (uint i; i < individualLength; i++) {
            address uniqueStudentAddr = _individual[i]._address;
            uint orgLength = memberOrganisations[uniqueStudentAddr].length;
            studentOrganisationIndex[uniqueStudentAddr][msg.sender] = orgLength;
            memberOrganisations[uniqueStudentAddr].push(msg.sender);
            if (uniqueStudent[uniqueStudentAddr] == false) {
                totalUsers++;
                uniqueStudent[uniqueStudentAddr] = true;
            }
        }
    }

    function revoke(address[] calldata _individual) public {
        require(
            validOrganisation[msg.sender] == true,
            "unauthorized Operation"
        );
        uint individualLength = _individual.length;
        for (uint i; i < individualLength; i++) {
            address uniqueIndividual = _individual[i];
            uint organisationIndex = studentOrganisationIndex[uniqueIndividual][
                msg.sender
            ];
            uint orgLength = memberOrganisations[uniqueIndividual].length;

            memberOrganisations[uniqueIndividual][
                organisationIndex
            ] = memberOrganisations[uniqueIndividual][orgLength - 1];
            memberOrganisations[uniqueIndividual].pop();
        }
    }

    function getOrganizations() public view returns (address[] memory) {
        return Organisations;
    }

    function getUserOrganisatons(
        address _userAddress
    ) public view returns (address[] memory) {
        return (memberOrganisations[_userAddress]);
    }
}
