// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

import "./ERC20.sol";
import "./IERC677Receiver.sol";

contract ERC667 is ERC20 {
    function transferAndCall(address recipient, uint amount, bytes calldata data) public returns (bool) {
        bool success = _transfer(msg.sender, recipient, amount);
        if (success){
            IERC677Receiver(recipient).onTokenTransfer(msg.sender, amount, data);
        }
        return success;
    }
}
