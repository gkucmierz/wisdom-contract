// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

import "./ERC20.sol";
import "./IERC667Receiver.sol";

/**
  * @title ERC667
  * @dev ERC667 token standard
  */
contract ERC667 is ERC20 {

    /**
      * @dev Transfer token to a contract address with additional data if the recipient is a contact
      * @param recipient The address to transfer to
      * @param amount The amount to be transferred
      * @param data The extra data to be passed to the receiving contract
      */
    function transferAndCall(address recipient, uint amount, bytes calldata data) public returns (bool) {
        bool success = _transfer(msg.sender, recipient, amount);
        if (success){
            IERC667Receiver(recipient).onTokenTransfer(msg.sender, amount, data);
        }
        return success;
    }
}
