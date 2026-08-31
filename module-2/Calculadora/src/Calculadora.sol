// SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

contract Calculadora {

    uint256 public result;
    address public admin;

    // Events
    event Addition(uint256 num1_, uint256 num2_, uint256 result_);
    event Substract(uint256 num1_, uint256 num2_, uint256 result_);
    event Multiplier(uint256 num1_, uint256 num2_, uint256 result_);
    event Division(uint256 num1_, uint256 num2_, uint256 result_);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not allowed.");
        _;
    }

    constructor(uint256 result_, address admin_) {
        result = result_;
        admin = admin_;
    }

    // Functions 

    // 1.- Addition
    function addition(uint256 num1_, uint256 num2_) external returns (uint256 result_) {
        result_ = num1_ + num2_;
        result = result_;
        emit Addition(num1_, num2_, result_);
    }

    // 2.- Substract
    function substract(uint256 num1_, uint256 num2_) external returns (uint256 result_) {
        result_ = num1_ - num2_;
        result = result_;
        emit Substract(num1_, num2_, result_);
    }

    // 3.- Multiplier
    function multiplier(uint256 num1_, uint256 num2_) external returns (uint256 result_) {
        result_ = num1_ * num2_;
        result = result_;
        emit Multiplier(num1_, num2_, result_);
    }

    // 4.- Division
    function division(uint256 num1_, uint256 num2_) external onlyAdmin() returns (uint256 result_) {
        if(num2_ == 0) return 0;
        result_ = num1_ / num2_;
        result = result_;
        emit Division(num1_, num2_, result_);
    }

}