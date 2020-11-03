// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

import "./ERC667.sol";
import "./Pausable.sol";
import "./Issuable.sol";

/**
  * @title WisdomToken
  * @dev Final Experty Wisdom Token contract
  */
contract WisdomToken is ERC667, Pausable, Issuable {
    constructor() {
        name = 'Experty Wisdom Token';
        symbol = 'WIS';
        decimals = 18;
        totalSupply = 0;
    }

    /**
      * @dev Internal transfer function that is respecting token pause state
      * @param sender The address that is sending tokens
      * @param recipient The address to transfer to
      * @param amount The amount to be transferred
      */
    function _transfer(address sender, address recipient, uint256 amount)
        internal whenNotPaused override returns (bool) {
        return super._transfer(sender, recipient, amount);
    }

    /**
      * @dev Alive function that will be called only once after token deploy and token issue
      * @param _newOwner New owner address
      */
    function alive(address _newOwner) public {
        lock();
        unpause();
        changeOwner(_newOwner);
    }
}
