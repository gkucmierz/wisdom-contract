// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

contract WisdomToken {

  string public name = 'Wisdom Token';
  string public symbol = 'WIS';
  uint8 public decimals = 18;

  uint256 public totalSupply = 80_000_000;

  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public allowed;

  constructor() {
    balanceOf[msg.sender] = totalSupply;
  }

  function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
    require(balanceOf[sender] >= amount);
    balanceOf[sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(sender, recipient, amount);
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return allowed[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    require(balanceOf[msg.sender] >= amount);
    allowed[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    require(allowed[sender][msg.sender] >= amount);
    _transfer(sender, recipient, amount);
    allowed[sender][msg.sender] -= amount;
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
