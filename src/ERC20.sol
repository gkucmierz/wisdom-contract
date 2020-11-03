// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

/**
  * @title Standard ERC20 token
  *
  * @dev Implementation of the basic standard token
  * @dev https://github.com/ethereum/EIPs/issues/20
  */
contract ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /**
      * @dev Gets the balance of the specified address
      * @param address The address to query the the balance of
      * @return An uint representing the amount owned by the passed address
      */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) private allowed;

    /**
      * @dev Internal transfer function that is making token transfer
      * @param sender The address that is sending tokens
      * @param recipient The address to transfer to
      * @param amount The amount to be transferred
      */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual returns (bool) {
        require(balanceOf[sender] >= amount);
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    /**
      * @dev Transfer token for a specified address
      * @param recipient The address to transfer to
      * @param amount The amount to be transferred
      */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    /**
      * @dev Function to check the amount of tokens than an owner allowed to a spender
      * @param holder address The address which owns the funds
      * @param spender address The address which will spend the funds
      * @return A uint specifying the amount of tokens still available for the spender
      */
    function allowance(address holder, address spender) public view returns (uint256) {
        return allowed[holder][spender];
    }

    /**
      * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender
      * @param spender The address which will spend the funds
      * @param amount The amount of tokens to be spent
      */
    function approve(address spender, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount);
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
      * @dev Transfer tokens from one address to another
      * @param sender address The address which you want to send tokens from
      * @param recipient address The address which you want to transfer to
      * @param amount uint256 the amount of tokens to be transferred
      */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(allowed[sender][msg.sender] >= amount);
        _transfer(sender, recipient, amount);
        allowed[sender][msg.sender] -= amount;
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed holder, address indexed spender, uint256 value);
}
