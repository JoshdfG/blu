// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
struct Individual {
    address _address;
    string _name;
    bool _active;
}

interface IFACTORY {
    function register(Individual[] calldata _individual) external;

    function revoke(address[] calldata _individual) external;
}
