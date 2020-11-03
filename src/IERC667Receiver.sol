// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

/**
  * @title ERC667 Receiver Interface
  * @dev Interface for receiver of ERC667 token transfers
  */
interface IERC667Receiver {

    /**
      * @dev Transfer token to a contract address with additional data if the recipient is a contact
      * @param from The address that tokens coming from
      * @param amount The amount that is transferred
      * @param data The extra data that is passed to the receiving contract
      */
    function onTokenTransfer(address from, uint256 amount, bytes calldata data) external;
}
