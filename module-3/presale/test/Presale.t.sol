// SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import "forge-std/Test.sol";
import "../src/Presale.sol";

contract PresaleTest is Test{

    Presale presale;

    address saleTokenAddress = vm.addr(1);
    address usdtAddress = vm.addr(1);
    address usdcAddress = vm.addr(1);
    address fundsReceiverAddress = vm.addr(1);
    address dataFeedAddress = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;
    uint256 maxSellingAmount = 3000000 * 1e18;
    uint256 startingTime = block.timestamp;
    uint256 endingTime = block.timestamp + 5000;
    uint256[][3] phases;

    function setUp() public {
        phases[0] = [10000000 * 1e18, 5000, block.timestamp + 1000];
        phases[1] = [10000000 * 1e18, 500, block.timestamp + 1000];
        phases[2] = [10000000 * 1e18, 50, block.timestamp + 1000];
        presale = new Presale(saleTokenAddress, usdtAddress, usdcAddress, fundsReceiverAddress, dataFeedAddress, maxSellingAmount, startingTime, endingTime, phases);
    }
}