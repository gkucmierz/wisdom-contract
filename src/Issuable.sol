// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

import "./ERC20.sol";
import "./Ownable.sol";

contract Issuable is ERC20, Ownable {
    bool locked = false;

    modifier whenUnlocked() {
        require(!locked);
        _;
    }

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

    function lock() internal onlyOwner whenUnlocked {
        locked = true;
    }
}
