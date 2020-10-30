// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

interface IERC677Receiver {
    function onTokenTransfer(address from, uint256 amount, bytes calldata data) external;
}
