// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

import "./ERC667.sol";
import "./ERCTransferFrom.sol";
import "./Pausable.sol";
import "./Issuable.sol";

contract WisdomToken is ERC667, ERCTransferFrom, Pausable, Issuable {
    constructor() {
        name = 'Experty Wisdom Token';
        symbol = 'WIS';
        decimals = 18;
        totalSupply = 0;
    }

    function _transfer(address sender, address recipient, uint256 amount)
        internal whenNotPaused override returns (bool) {
        return super._transfer(sender, recipient, amount);
    }

    function alive(address _newOwner) public {
        lock();
        unpause();
        changeOwner(_newOwner);
    }
}
