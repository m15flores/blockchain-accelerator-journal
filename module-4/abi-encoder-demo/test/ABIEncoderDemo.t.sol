// SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import "forge-std/Test.sol";
import "../src/ABIEncoderDemo.sol";

/**
 * @title ABIEncoderDemoTest
 * @notice Comprehensive test targeting 100% coverage for ABIEncoderDemo
 */
contract ABIEncoderDemoTest is Test {
    ABIEncoderDemo demo;

    /**
     * @dev Deploy a fresh contract before each test
     */
    function setUp() public {
        demo = new ABIEncoderDemo();
    }

    /**
     * @dev Pool id must be invariant to token ordering (tokens are sorted internally)
     */
    function test_CreatePoolIdentifierSameForBothTokenOrders() public {
        address tokenA = address(0x100);
        address tokenB = address(0x200);
        uint24 fee = 3000;

        bytes32 idAB = demo.createPoolIdentifier(tokenA, tokenB, fee);
        bytes32 idBA = demo.createPoolIdentifier(tokenB, tokenA, fee);

        assertEq(idAB, idBA, "Tokens are not correctly sorted.");
    }

    function test_CreatePoolIdentifier_DifferentFeeDifferentId() public {
        address tokenA = address(0x100);
        address tokenB = address(0x200);
        uint24 fee0 = 3000;
        uint24 fee1 = 5000;

        bytes32 idLow = demo.createPoolIdentifier(tokenA, tokenB, fee0);
        bytes32 idHigh = demo.createPoolIdentifier(tokenB, tokenA, fee1);

        assertTrue(idLow != idHigh, "Different fees must yield different ids.");
    }

    function test_EncondeTradingPosition_ReturnsExpectedDataAndHash() public {
        address user = address(0x1234);
        address tokenIn = address(0xA1);
        address tokenOut = address(0xB2);
        uint256 amountIn = 1 ether;
        uint256 amountOut = 2 ether;

        // Freeze block timestamp to a known value
        uint256 fixTimestamp = 1_700_000_000;
        vm.warp(fixTimestamp);

        (bytes32 positionId, bytes memory encodedData) = demo.encodeTradingPosition(user, tokenIn, tokenOut, amountIn, amountOut);

        bytes memory expected = abi.encodePacked(user, tokenIn, tokenOut, amountIn, amountOut, fixTimestamp);

        assertEq(encodedData, expected, "Encoded training position missmatch.");
        assertEq(positionId, keccak256(expected), "PositionId must be keccak of encodedData.");
    }

    function test_EncodeSwapData_EncodesPathAmountsDeadline() public view {
        address[] memory path = new address[](3);
        path[0] = address(0x1);
        path[1] = address(0x2);
        path[2] = address(0x3);

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 10;
        amounts[1] = 20;
        amounts[2] = 30;

        uint256 deadline = 999;

        bytes memory pathData;
        for(uint256 i = 0; i < path.length; i++) {
            pathData = abi.encodePacked(pathData, path[i]);
        }

        bytes memory amountsData;
        for(uint256 i = 0; i < amounts.length; i++) {
            amountsData = abi.encodePacked(amountsData, amounts[i]);
        }

        bytes memory expected = abi.encodePacked(pathData, amountsData, deadline);
        bytes memory actual = demo.encodeSwapData(path, amounts, deadline);

        assertEq(expected, actual, "Swap data encoding missmatch.");
    }

    function test_EncodeSwapData_RevertsOnLengthMissmatch() public {
        address[] memory path = new address[](2);
        path[0] = address(0x1);
        path[1] = address(0x2);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 10;

        uint256 deadline = 999;

        vm.expectRevert(abi.encodeWithSignature("Error(string)", "Arrays length missmatch."));
        demo.encodeSwapData(path, amounts, deadline);
    }
}