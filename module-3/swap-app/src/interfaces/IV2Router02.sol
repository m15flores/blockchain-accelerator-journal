// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.34;

interface IV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to, 
        uint deadline
    ) external returns (uint amountA, uint amountB);
}