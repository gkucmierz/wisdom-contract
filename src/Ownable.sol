// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

/**
  * @title Ownable
  * @dev The Ownable contract has an owner address, and provides basic authorization control
  * functions, this simplifies the implementation of "user permissions"
  */
contract Ownable {
    address owner;
    address newOwner;

    constructor() {
        owner = msg.sender;
    }

    /**
      * @dev Throws if called by any account other than the owner
      */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
      * @dev Allows the current owner to transfer control of the contract to a _newOwner
      * @param _newOwner The address to transfer ownership to
      */
    function changeOwner(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    /**
      * @dev Accept ownership by new owner
      */
    function acceptOwner() public {
        require(newOwner == msg.sender);
        owner = msg.sender;
        emit TransferOwnership(msg.sender);
    }

    event TransferOwnership(address newOwner);
}
