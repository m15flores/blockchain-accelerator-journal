// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.24;

import "./interfaces/IResult.sol";

contract Addition {

    address public resultAddress;

    constructor(address resultAddress_) {
        resultAddress = resultAddress_;
    }

    function add(uint256 num1_, uint256 num2_) external {
        uint256 result = num1_ + num2_;
        IResult(resultAddress).setResult(result);
    }

    function setFee(uint256 fee_) external {
        IResult(resultAddress).setFee(fee_);
    }    
}