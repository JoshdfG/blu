// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// import "./SchoolCertificate.sol";
import "./employeeNFT.sol";

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

    function employee_of_the_month_NFT(
        address _Admin,
        string memory Name,
        string memory Symbol,
        string memory Uri
    ) public returns (address) {
        employeeNFT newEmployeeNFT = new employeeNFT(_Admin, Name, Symbol, Uri);
        return address(newEmployeeNFT);
    }

    // function createMentorsSpok(
    //     string memory Name,
    //     string memory Symbol,
    //     address institution
    // ) public returns (address) {
    //     employeeNFT newCertificateAdd = new employeeNFT(
    //         Name,
    //         Symbol,
    //         institution
    //     );
    //     return address(newCertificateAdd);
    // }

    function completePackage(
        string memory Name,
        string memory Symbol,
        string memory Uri,
        address _Admin
    )
        external
        returns (
            address newEmployeeNFT // address newMentorsSpok
        )
    {
        // newCertificateAdd = createCertificateNft(Name, Symbol, _Admin);
        newEmployeeNFT = employee_of_the_month_NFT(_Admin, Name, Symbol, Uri);
        // newMentorsSpok = createMentorsSpok(Name, Symbol, _Admin);
    }
}
