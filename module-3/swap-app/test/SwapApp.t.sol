// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.34;

import "forge-std/Test.sol";
import "../src/SwapApp.sol";

contract SwapAppTest is Test {

    SwapApp app;
    address uniswapV2SwapRouterAddress = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    address user = 0x9b64203878F24eB0CDF55c8c6fA7D08Ba0cF77E5; // Address with USDT in Arbitrum Mainnet
    address USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9; // USDT Address in Arbitrum Mainnet
    address DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1; // DAI Address in Arbitrum Mainnet

    function setUp() public {
        app = new SwapApp(uniswapV2SwapRouterAddress);
    }

    function testHasBeenDeployedCorrectly() public view {
        assert(app.v2Router02Address() == uniswapV2SwapRouterAddress);
    }

    function testSwapTokensCorrectly() public {
        vm.startPrank(user);
        
        uint256 amountIn = 5 * 1e6;
        uint256 amountOutMin = 4 * 1e18;
        uint256 deadline = 1791290928 + 10000000000;
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = DAI;
        IERC20(USDT).approve(address(app), amountIn);

        uint256 usdtBalanceBefore = IERC20(USDT).balanceOf(user);
        uint256 daiBalanceBefore = IERC20(DAI).balanceOf(user);
        
        app.swapTokens(amountIn, amountOutMin, path, deadline);

        uint256 usdtBalanceAfter = IERC20(USDT).balanceOf(user);
        uint256 daiBalanceAfter = IERC20(DAI).balanceOf(user);

        assert(usdtBalanceAfter == usdtBalanceBefore - amountIn);
        assert(daiBalanceAfter > daiBalanceBefore);

        vm.stopPrank();
    }
}