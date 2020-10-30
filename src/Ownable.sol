// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address owner;
    address newOwner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwner() public {
        require(newOwner == msg.sender);
        owner = msg.sender;
        emit TransferOwnership(msg.sender);
    }

    event TransferOwnership(address newOwner);
}
