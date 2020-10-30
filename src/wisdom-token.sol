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

interface IERC677Receiver {
    function onTokenTransfer(address from, uint256 amount, bytes calldata data) external;
}

contract ERC667 is ERC20 {
    function transferAndCall(address recipient, uint amount, bytes calldata data) public returns (bool) {
        bool success = _transfer(msg.sender, recipient, amount);
        if (success){
            IERC677Receiver(recipient).onTokenTransfer(msg.sender, amount, data);
        }
        return success;
    }
}

contract ERCTransferFrom is ERC667 {

    struct TransferFrom {
        address to;
        uint256 amount;
        uint256 nonce;
    }

    struct TransferFromUntil {
        address to;
        uint256 amount;
        uint256 nonce;
        uint256 untilBlock;
    }

    mapping (address => mapping (address => uint256)) public nonceOf;

    string private TRANSFER_FROM_TYPEHASH;
    string private TRANSFER_FROM_UNTIL_TYPEHASH;
    uint256 private chainId;
    address private verifyingContract;
    string private EIP712_DOMAIN_TYPEHASH;
    bytes32 private DOMAIN_SEPARATOR;
    string private PREFIX;

    function initTransferFrom() internal {
        TRANSFER_FROM_TYPEHASH = "TransferFrom(address to,uint256 amount,uint256 nonce)";
        TRANSFER_FROM_UNTIL_TYPEHASH = "TransferFromUntil(address to,uint256 amount,uint256 nonce,uint256 untilBlock)";
        chainId = getChainID();
        verifyingContract = address(this);
        EIP712_DOMAIN_TYPEHASH = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256("Experty Wisdom Token"),
            keccak256("1.4.4"),
            chainId,
            verifyingContract
        ));
        PREFIX = "\\x19\\x01";
    }

    function getChainID() private pure returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function hashTransferFrom(TransferFrom memory _transferFrom) private view returns (bytes32) {
        return keccak256(abi.encodePacked(
            PREFIX,
            DOMAIN_SEPARATOR,
            TRANSFER_FROM_TYPEHASH,
            _transferFrom.to,
            _transferFrom.amount,
            _transferFrom.nonce
        ));
    }

    function hashTransferFromUntil(TransferFromUntil memory _transferFromUntil) private view returns (bytes32) {
        return keccak256(abi.encodePacked(
            PREFIX,
            DOMAIN_SEPARATOR,
            TRANSFER_FROM_UNTIL_TYPEHASH,
            _transferFromUntil.to,
            _transferFromUntil.amount,
            _transferFromUntil.nonce,
            _transferFromUntil.untilBlock
        ));
    }

    function _transfer(address from, address recipient, uint256 amount, uint256 nonce) private returns (bool) {
        require(from != address(0x0));
        uint256 nextNonce = nonceOf[from][recipient] + 1;
        require(nonce == nextNonce);
        bool success = _transfer(from, recipient, amount);
        if (success) nonceOf[from][recipient] = nextNonce;
        return success;
    }

    function transferFrom(
        address _recipient, uint256 _amount, uint256 _nonce,
        uint8 _v, bytes32 _r, bytes32 _s) public returns (bool) {
        bytes32 hash = hashTransferFrom(TransferFrom({
            to: _recipient,
            amount: _amount,
            nonce: _nonce
        }));
        address from = ecrecover(hash, _v, _r, _s);
        return _transfer(from, _recipient, _amount, _nonce);
    }

    function transferFromUntil(
        address _recipient, uint256 _amount, uint256 _nonce, uint256 _untilBlock,
        uint8 _v, bytes32 _r, bytes32 _s) public returns (bool) {
        bytes32 hash = hashTransferFromUntil(TransferFromUntil({
            to: _recipient,
            amount: _amount,
            nonce: _nonce,
            untilBlock: _untilBlock
        }));
        address from = ecrecover(hash, _v, _r, _s);
        return _transfer(from, _recipient, _amount, _nonce);
    }
}

contract Ownable {
    address owner;
    address newOwner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwner() public {
        require(newOwner == msg.sender);
        owner = msg.sender;
        emit TransferOwnership(msg.sender);
    }

    event TransferOwnership(address newOwner);
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

contract WisdomToken is ERCTransferFrom, Pausable, Issuable {
    constructor() {
        name = 'Experty Wisdom Token';
        symbol = 'WIS';
        decimals = 18;
        totalSupply = 0;
    }

    function _transfer(address sender, address recipient, uint256 amount)
        internal whenNotPaused override returns (bool) {
        return super._transfer(sender, recipient, amount);
    }

    function alive(address _newOwner) public {
        lock();
        unpause();
        changeOwner(_newOwner);
        initTransferFrom();
    }
}
