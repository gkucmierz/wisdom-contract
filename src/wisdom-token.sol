// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

contract ERC20 {

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;

  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public allowed;

  bool paused = false;

  constructor() {
    balanceOf[msg.sender] = totalSupply;
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

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed holder, address indexed spender, uint256 value);
}

contract Ownable {
  address public owner;

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    owner = newOwner;
    emit TransferOwnership(newOwner);
  }

  event TransferOwnership(address);
}

contract Pausable is Ownable {

  bool public paused = true;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }

  event Pause();
  event Unpause();
}

contract WisdomToken is Pausable {

  string public name = 'Wisdom Token';
  string public symbol = 'WIS';
  uint8 public decimals = 18;
  uint256 public totalSupply = 0;

  constructor() {
  }

}
