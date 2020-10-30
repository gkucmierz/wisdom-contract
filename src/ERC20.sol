// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

contract ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowed;

    function _transfer(address sender, address recipient, uint256 amount) internal virtual returns (bool) {
        require(balanceOf[sender] >= amount);
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function allowance(address holder, address spender) public view returns (uint256) {
        return allowed[holder][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount);
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(allowed[sender][msg.sender] >= amount);
        _transfer(sender, recipient, amount);
        allowed[sender][msg.sender] -= amount;
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed holder, address indexed spender, uint256 value);
}
