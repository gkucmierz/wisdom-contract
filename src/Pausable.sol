// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

import "./Ownable.sol";

contract Pausable is Ownable {
    bool public paused = true;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }

    event Pause();
    event Unpause();
}
