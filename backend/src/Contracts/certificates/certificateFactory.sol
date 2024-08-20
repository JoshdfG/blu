// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// import "./SchoolCertificate.sol";
import "./SchoolsNFT.sol";

contract certificateFactory {
    address Admin;

    constructor() {
        Admin = msg.sender;
    }

    // function createCertificateNft(
    //     string memory Name,
    //     string memory Symbol,
    //     address institution
    // ) public returns (address) {
    //     Certificate newCertificateAdd = new Certificate(
    //         Name,
    //         Symbol,
    //         institution
    //     );
    //     return address(newCertificateAdd);
    // }

    function createAttendanceNft(
        string memory Name,
        string memory Symbol,
        string memory Uri,
        address _Admin
    ) public returns (address) {
        CustomERC1155 newSchoolsNFT = new CustomERC1155(
            Name,
            Symbol,
            Uri,
            _Admin
        );
        return address(newSchoolsNFT);
    }

    function createMentorsSpok(
        string memory Name,
        string memory Symbol,
        address institution
    ) public returns (address) {
        CustomERC1155 newCertificateAdd = new CustomERC1155(
            Name,
            Symbol,
            institution
        );
        return address(newCertificateAdd);
    }

    function completePackage(
        string memory Name,
        string memory Symbol,
        string memory Uri,
        address _Admin
    )
        external
        returns (
            address newCertificateAdd,
            address newSchoolsNFT,
            address newMentorsSpok
        )
    {
        // newCertificateAdd = createCertificateNft(Name, Symbol, _Admin);
        newSchoolsNFT = createAttendanceNft(Name, Symbol, Uri, _Admin);
        newMentorsSpok = createMentorsSpok(Name, Symbol, _Admin);
    }
}
