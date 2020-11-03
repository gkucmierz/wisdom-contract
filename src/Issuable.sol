// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

import "./ERC20.sol";
import "./Ownable.sol";

/**
  * @title Issuable
  *
  * @dev Allows to issue tokens in contract locked phase after deploy
  */
contract Issuable is ERC20, Ownable {
    bool locked = false;

    /**
      * @dev Throws if called after locked phase
      */
    modifier whenUnlocked() {
        require(!locked);
        _;
    }

    /**
      * @dev Allows the current owner to transfer control of the contract to a _newOwner
      * @param addr[] The address array of tokens beneficients to be issued
      * @param amount[] The amounts array of tokens beneficients to be issued
      */
    function issue(address[] memory addr, uint256[] memory amount) public onlyOwner whenUnlocked {
        require(addr.length == amount.length);
        uint8 i;
        uint256 sum = 0;
        for (i = 0; i < addr.length; ++i) {
            balanceOf[addr[i]] = amount[i];
            emit Transfer(address(0x0), addr[i], amount[i]);
            sum += amount[i];
        }
        totalSupply += sum;
    }

    /**
      * @dev Lock contract forever
      */
    function lock() internal onlyOwner whenUnlocked {
        locked = true;
    }
}
