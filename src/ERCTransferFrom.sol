// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

import "./ERC667.sol";

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

    bytes32 private TRANSFER_FROM_TYPEHASH = keccak256("TransferFrom(address to,uint256 amount,uint256 nonce)");
    bytes32 private TRANSFER_FROM_UNTIL_TYPEHASH = keccak256(
        "TransferFromUntil(address to,uint256 amount,uint256 nonce,uint256 untilBlock)");
    uint256 private chainId = getChainID();
    address private verifyingContract = address(this);
    string private PREFIX = "\\x19\\x01";
    bytes32 constant salt = 0xeb338c7e2d28aad50a8209fc9f5f2eea691acfccf5e9a04fea0d5b95ba3c4c87;
    bytes32 private EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private DOMAIN_SEPARATOR = keccak256(abi.encode(
        EIP712_DOMAIN_TYPEHASH,
        keccak256("Experty Wisdom Token"),
        keccak256("1.5.0"),
        chainId,
        verifyingContract,
        salt
    ));

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
        require(block.number <= _untilBlock);
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
