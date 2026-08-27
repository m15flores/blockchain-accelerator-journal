// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.24;

contract Result {

    uint256 public result;
    address public owner;
    uint256 public fee;

    constructor(address owner_) {
        owner = owner_;
        fee = 5;
    }

    function setResult(uint256 result_) external {
        result = result_;
    }

    function setFee(uint256 fee_) external {
        // require(tx.origin == owner, "Only the owner can set the fee.");
        if(tx.origin != owner) revert();
        fee = fee_;
    }
}