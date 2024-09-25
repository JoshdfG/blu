// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../../Library/Errors/FactoryError/Error.sol";
import "../../Interfaces/IFactory.sol";
import "../../Interfaces/ICERTFACTORY.sol";
import "../../Library/Errors/FactoryError/Error.sol";
import "../../Contracts/organizations/organisation.sol";

library FactoryLibrary {
    struct Layout {
        address Admin;
        address organisationAdmin;
        address certificateFactory;
        address[] Organisations;
        mapping(address => bool) validOrganisation;
        mapping(address => mapping(address => uint)) staffOrganisationIndex;
        mapping(address => address[]) memberOrganisations;
        mapping(address => bool) uniqueStudent;
        uint totalUsers;
    }

    function createorganisation(
        string memory _organisation,
        string memory _uri,
        string memory _symbol,
        string memory _adminName,
        Layout storage l
    ) external returns (address Organisation, address Nft) {
        l.organisationAdmin = msg.sender;
        organisation OrganisationAddress = new organisation(
            _organisation,
            l.organisationAdmin,
            _adminName,
            _uri
        );
        l.Organisations.push(address(OrganisationAddress));

        l.validOrganisation[address(OrganisationAddress)] = true;

        address employeNFT = ICERTFACTORY(l.certificateFactory).completePackage(
            _organisation,
            _uri,
            _symbol,
            address(OrganisationAddress)
        );

        OrganisationAddress.initialize(address(employeNFT));

        uint orgLength = l.memberOrganisations[msg.sender].length;
        l.staffOrganisationIndex[msg.sender][
            address(OrganisationAddress)
        ] = orgLength;
        l.memberOrganisations[msg.sender].push(address(OrganisationAddress));

        Nft = address(employeNFT);
        Organisation = address(OrganisationAddress);
    }

    function register(
        Individual[] calldata _individual,
        Layout storage l
    ) public {
        if (!l.validOrganisation[msg.sender]) {
            revert OrgError.UNAUTHORIZED_OPERATION();
        }
        uint individualLength = _individual.length;
        for (uint i; i < individualLength; i++) {
            address uniqueStudentAddr = _individual[i]._address;
            uint orgLength = l.memberOrganisations[uniqueStudentAddr].length;
            l.staffOrganisationIndex[uniqueStudentAddr][msg.sender] = orgLength;
            l.memberOrganisations[uniqueStudentAddr].push(msg.sender);
            if (l.uniqueStudent[uniqueStudentAddr] == false) {
                l.totalUsers++;
                l.uniqueStudent[uniqueStudentAddr] = true;
            }
        }
    }

    function revoke(address[] calldata _individual, Layout storage l) public {
        if (!l.validOrganisation[msg.sender]) {
            revert OrgError.UNAUTHORIZED_OPERATION();
        }
        uint individualLength = _individual.length;
        for (uint i; i < individualLength; i++) {
            address uniqueIndividual = _individual[i];
            uint organisationIndex = l.staffOrganisationIndex[uniqueIndividual][
                msg.sender
            ];
            uint orgLength = l.memberOrganisations[uniqueIndividual].length;

            l.memberOrganisations[uniqueIndividual][organisationIndex] = l
                .memberOrganisations[uniqueIndividual][orgLength - 1];
            l.memberOrganisations[uniqueIndividual].pop();
        }
    }
}
