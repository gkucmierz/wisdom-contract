// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

import "./Ownable.sol";

/**
  * @title Pausable
  * @dev Base contract which allows to implement an emergency stop mechanism
  */
contract Pausable is Ownable {
    bool public paused = true;

    /**
      * @dev Modifier to make a function callable only when the contract is not paused
      */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
      * @dev Modifier to make a function callable only when the contract is paused
      */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
      * @dev Called by the owner to pause, triggers stopped state
      */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
      * @dev Called by the owner to unpause, returns to normal state
      */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }

    event Pause();
    event Unpause();
}
