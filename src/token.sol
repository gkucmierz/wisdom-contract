// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

contract WisdomToken {

  string public name = 'Wisdom Token';
  string public symbol = 'WIS';
  uint8 public decimals = 18;

  uint256 public totalSupply = 80_000_000 ether;

  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public allowed;

  address owner;
  bool paused = false;

  constructor() {
    balanceOf[msg.sender] = totalSupply;
    owner = msg.sender;
  }

  function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
    require(!paused);
    require(balanceOf[sender] >= amount);
    balanceOf[sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(sender, recipient, amount);
  }

  function transfer(address recipient, uint256 amount) public returns (bool) {
    _transfer(msg.sender, recipient, amount);
  }

  function allowance(address holder, address spender) public view returns (uint256) {
    return allowed[holder][spender];
  }

  function approve(address spender, uint256 amount) public returns (bool) {
    require(balanceOf[msg.sender] >= amount);
    allowed[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
  }

  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    require(allowed[sender][msg.sender] >= amount);
    _transfer(sender, recipient, amount);
    allowed[sender][msg.sender] -= amount;
  }

  function transferOwnership(address newOwner) public {
    require(msg.sender == owner);
    owner = newOwner;
  }

  function setPaused(bool _paused) public {
    paused = _paused;
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
