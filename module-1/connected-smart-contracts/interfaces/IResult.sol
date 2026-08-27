// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.24;

interface IResult {
    function setResult(uint256 result_) external;
    function setFee(uint256 fee_) external;
}