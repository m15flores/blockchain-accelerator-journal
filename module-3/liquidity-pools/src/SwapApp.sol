// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.34;

import "./interfaces/IV2Router02.sol";
import "./interfaces/IFactory.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract SwapApp {

    using SafeERC20 for IERC20;

    address public v2Router02Address;
    address public uniswapFactoryAddress;
    address public USDT;
    address public DAI;

    event SwapTokens(address tokenIn_, address tokenOut_, uint256 amountIn_, uint256 amountOut_);
    event AddLiquidity(address token0, address token1, uint256 lpTokenAmount);

    constructor(address v2Router02Address_, address uniswapFactoryAddress_, address USDT_, address DAI_) {
        v2Router02Address = v2Router02Address_;
        uniswapFactoryAddress = uniswapFactoryAddress_;
        USDT = USDT_;
        DAI = DAI_;
    }

    function swapTokens(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, address to_, uint256 deadline_) public returns (uint256) {
        IERC20(path_[0]).safeTransferFrom(msg.sender, address(this), amountIn_);

        IERC20(path_[0]).approve(v2Router02Address, amountIn_);
        uint[] memory amountOuts = IV2Router02(v2Router02Address).swapExactTokensForTokens(amountIn_, amountOutMin_, path_, to_, deadline_);

        emit SwapTokens(path_[0], path_[path_.length - 1], amountIn_, amountOuts[amountOuts.length - 1]);

        return amountOuts[amountOuts.length - 1];
    }

    function addLiquidity(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, uint256 amountAMin_, uint256 amountBMin_, uint256 deadline_) external {
        // 1st : Swap Tokens
        IERC20(USDT).safeTransferFrom(msg.sender, address(this), amountIn_ / 2);
        uint256 swappedAmount = swapTokens(amountIn_ / 2, amountOutMin_, path_, address(this), deadline_);

        // 2nd : Add Liquidity
        IERC20(USDT).approve(v2Router02Address, amountIn_ / 2);
        IERC20(DAI).approve(v2Router02Address, swappedAmount);
        (, , uint256 lpTokenAmount) = IV2Router02(v2Router02Address).addLiquidity(USDT, DAI, amountIn_ / 2, swappedAmount, amountAMin_, amountBMin_, msg.sender, deadline_);

        emit AddLiquidity(USDT, DAI, lpTokenAmount);
    }

    function removeLiquidity(uint256 liquidityAmount_, uint256 amountAMin_, uint256 amountBMin_, address to_, uint256 deadline_) external {
        address lpTokenAddress = IFactory(uniswapFactoryAddress).getPair(USDT, DAI);
        IERC20(lpTokenAddress).safeTransferFrom(msg.sender, address(this), liquidityAmount_);
        IERC20(lpTokenAddress).approve(v2Router02Address, liquidityAmount_);
        IV2Router02(v2Router02Address).removeLiquidity(USDT, DAI, liquidityAmount_, amountAMin_, amountBMin_, to_, deadline_);
    }
}