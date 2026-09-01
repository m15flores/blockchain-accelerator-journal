// SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingAppTest is Test {

    StakingApp public stakingApp;
    StakingToken public stakingToken;

    // StakingToken parameters
    string name_ = "StakingToken";
    string symbol_ = "STK";

    // StakingApp parameters
    address owner_ = vm.addr(1);
    uint256 stakingPeriod_ = 1000000000000;
    uint256 fixedStakingAmount_ = 10;
    uint256 rewardPerPeriod_ = 1 ether;

    address randomUser = vm.addr(2);

    function setUp() external {
        stakingToken = new StakingToken(name_, symbol_);
        stakingApp = new StakingApp(address(stakingToken), owner_, stakingPeriod_, fixedStakingAmount_, rewardPerPeriod_);
    }

    function testStakingTokenCorrectlyDeployed() external view {
        assert(owner_ != address(0));
    }

    function testStakingAppCorrectlyDeployed() external view {
        assert(owner_ != address(0));
    }

    function testShouldRevertIfNotOwner() external {
        uint256 newStakingPeriod_ = 1;

        vm.expectRevert();
        stakingApp.changeStakingPeriod(newStakingPeriod_);
    }

    function testShouldChangeStakingPeriod() external {
        vm.startPrank(owner_);
        uint256 newStakingPeriod_ = 1;

        uint256 stakingPeriodBefore = stakingApp.stakingPeriod();
        stakingApp.changeStakingPeriod(newStakingPeriod_);
        uint256 stakingPeriodAfter = stakingApp.stakingPeriod();

        assert(stakingPeriodAfter != stakingPeriodBefore);
        assert(stakingPeriodAfter == newStakingPeriod_);

        vm.stopPrank();
    }

    function testContractReceivesEtherCorrectly() external {
        vm.startPrank(owner_);
        vm.deal(owner_, 1 ether);

        uint256 etherValue = 1 ether;

        uint256 balanceBefore = address(stakingApp).balance;
        (bool success, ) = address(stakingApp).call{value: etherValue}("");
        uint256 balanceAfter = address(stakingApp).balance;
        require(success, "Transfer failed.");

        assert(balanceAfter - balanceBefore == etherValue);

        vm.stopPrank();
    }

    // Deposit tests

    function testIncorrectAmoutShouldRevert() external {
        vm.startPrank(randomUser);

        uint256 depositAmount_ = 1;
        vm.expectRevert("Incorrect amount.");
        stakingApp.depositToken(depositAmount_);

        vm.stopPrank();
    }

    function testDepositTokenCorrectly() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount_ = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount_);
        
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBefore = stakingApp.elapsedPeriod(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount_);
        stakingApp.depositToken(tokenAmount_);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfter = stakingApp.elapsedPeriod(randomUser);

        assert(userBalanceAfter - userBalanceBefore == tokenAmount_);
        assert(elapsedPeriodBefore == 0);
        assert(elapsedPeriodAfter == block.timestamp);

        vm.stopPrank();
    }

    function testUserCannotDepositMoreThanOnce() external {
        vm.startPrank(randomUser);

        // First deposit
        uint256 tokenAmount_ = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount_);
        
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBefore = stakingApp.elapsedPeriod(randomUser);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount_);
        stakingApp.depositToken(tokenAmount_);
        
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfter = stakingApp.elapsedPeriod(randomUser);

        assert(userBalanceAfter - userBalanceBefore == tokenAmount_);
        assert(elapsedPeriodBefore == 0);
        assert(elapsedPeriodAfter == block.timestamp);

        // Second deposit
        stakingToken.mint(tokenAmount_);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount_);
        vm.expectRevert("User already deposited tokens.");
        stakingApp.depositToken(tokenAmount_);


        vm.stopPrank();
    }

    // Withdraw tests

    function testCanOnlyWithdrawWithoutDeposit() external {
        vm.startPrank(randomUser);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        stakingApp.withdrawTokens();
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);

        assert(userBalanceAfter == userBalanceBefore);

        vm.stopPrank();

    }

    function testWithdrawTokensCorrectly() external {
        vm.startPrank(randomUser);
        
        // Deposit
        uint256 tokenAmount_ = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount_);
        
        uint256 userBalanceBeforeDeposit = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBeforeDeposit = stakingApp.elapsedPeriod(randomUser);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount_);
        stakingApp.depositToken(tokenAmount_);
        
        uint256 userBalanceAfterDeposit = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfterDeposit = stakingApp.elapsedPeriod(randomUser);

        assert(userBalanceAfterDeposit - userBalanceBeforeDeposit == tokenAmount_);
        assert(elapsedPeriodBeforeDeposit == 0);
        assert(elapsedPeriodAfterDeposit == block.timestamp);

        // Withdraw

        uint256 userBalanceBeforeWithdraw = IERC20(stakingToken).balanceOf(randomUser);
        uint256 userBalanceInMappingBeforeWithdraw = stakingApp.userBalance(randomUser);
        stakingApp.withdrawTokens();
        uint256 userBalanceAfterWithdraw = IERC20(stakingToken).balanceOf(randomUser);

        assert(userBalanceAfterWithdraw == userBalanceBeforeWithdraw + userBalanceInMappingBeforeWithdraw);

        vm.stopPrank();
    }

    // ClaimRewards tests

    function testCannotClaimIfNotStaking() external {
        vm.startPrank(randomUser);

        vm.expectRevert("Not staking.");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function testCannotClaimIfNotElapsedTime() external {
        vm.startPrank(randomUser);

        // Deposit
        uint256 tokenAmount_ = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount_);
        
        uint256 userBalanceBeforeDeposit = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBeforeDeposit = stakingApp.elapsedPeriod(randomUser);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount_);
        stakingApp.depositToken(tokenAmount_);
        
        uint256 userBalanceAfterDeposit = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfterDeposit = stakingApp.elapsedPeriod(randomUser);

        assert(userBalanceAfterDeposit - userBalanceBeforeDeposit == tokenAmount_);
        assert(elapsedPeriodBeforeDeposit == 0);
        assert(elapsedPeriodAfterDeposit == block.timestamp);

        // Claim Rewards
        vm.expectRevert("Need to wait.");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function testShouldRevertIfNoEther() external {
        vm.startPrank(randomUser);

        // Deposit
        uint256 tokenAmount_ = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount_);
        
        uint256 userBalanceBeforeDeposit = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBeforeDeposit = stakingApp.elapsedPeriod(randomUser);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount_);
        stakingApp.depositToken(tokenAmount_);
        
        uint256 userBalanceAfterDeposit = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfterDeposit = stakingApp.elapsedPeriod(randomUser);

        assert(userBalanceAfterDeposit - userBalanceBeforeDeposit == tokenAmount_);
        assert(elapsedPeriodBeforeDeposit == 0);
        assert(elapsedPeriodAfterDeposit == block.timestamp);

        // Claim Rewards
        vm.warp(block.timestamp + stakingPeriod_);
        vm.expectRevert("Transfer failed.");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function testCanClaimRewardsCorrectly() external {
        vm.startPrank(randomUser);

        // Deposit
        uint256 tokenAmount_ = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount_);
        
        uint256 userBalanceBeforeDeposit = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBeforeDeposit = stakingApp.elapsedPeriod(randomUser);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount_);
        stakingApp.depositToken(tokenAmount_);
        
        uint256 userBalanceAfterDeposit = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfterDeposit = stakingApp.elapsedPeriod(randomUser);

        assert(userBalanceAfterDeposit - userBalanceBeforeDeposit == tokenAmount_);
        assert(elapsedPeriodBeforeDeposit == 0);
        assert(elapsedPeriodAfterDeposit == block.timestamp);

        vm.stopPrank();

        // Need ether on the App
        vm.startPrank(owner_);
        
        uint256 etherAmount = 1000 ether;
        vm.deal(owner_, etherAmount);
        (bool success, ) = address(stakingApp).call{value: etherAmount}("");
        require(success, "Test transfer failed.");
        
        vm.stopPrank();
        
        // Claim Rewards for randomUser
        vm.startPrank(randomUser);

        vm.warp(block.timestamp + stakingPeriod_);

        uint256 etherAmountBefore = address(randomUser).balance;        
        stakingApp.claimRewards();        
        uint256 etherAmountAfter = address(randomUser).balance;
        uint256 elapsedPeriod = stakingApp.elapsedPeriod(randomUser);

        assert(etherAmountAfter - etherAmountBefore == rewardPerPeriod_);
        assert(elapsedPeriod == block.timestamp);

        vm.stopPrank();
    }
}