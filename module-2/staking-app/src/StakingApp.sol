// SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingApp is Ownable {

    address public stakingToken;
    uint256 public stakingPeriod;
    mapping(address => uint256) public userBalance;
    uint256 public fixedStakingAmount;
    mapping(address => uint256) public elapsedPeriod;
    uint256 public rewardPerPeriod;


    event ChangeStakingPeriod(uint256 newStakingPeriod_);
    event DepositTokens(address userAddress_, uint256 depositAmount_);
    event WithdrawTokens(address userAddress_, uint256 withdrawAmount_);
    event EtherSent(uint256 amount_);

    constructor(address stakingToken_, address owner_, uint256 stakingPeriod_, uint256 fixedStakingAmount_, uint256 rewardPerPeriod_) Ownable(owner_) {
        
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedStakingAmount = fixedStakingAmount_;
        rewardPerPeriod = rewardPerPeriod_;
    }

    function depositToken(uint256 amount_) external {
        require(amount_ == fixedStakingAmount, "Incorrect amount.");
        require(userBalance[msg.sender] == 0, "User already deposited tokens.");

        IERC20(stakingToken).transferFrom(msg.sender, address(this), amount_);
        userBalance[msg.sender] += amount_;
        elapsedPeriod[msg.sender] = block.timestamp;

        emit DepositTokens(msg.sender, amount_);
    }

    function withdrawTokens() external {     
        uint256 userBalance_ = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        IERC20(stakingToken).transfer(msg.sender, userBalance_);

        emit WithdrawTokens(msg.sender, userBalance_);      
    }

    // 3.- Claim rewards
    function claimRewards() external {
        // 1.- Check balance
        require(userBalance[msg.sender] == fixedStakingAmount, "Not staking.");

        // 2.- Calculate reward amount
        uint256 elapsedPeriod_ = block.timestamp - elapsedPeriod[msg.sender];
        require(elapsedPeriod_ >= stakingPeriod, "Need to wait.");

        // 3.- Update state
        elapsedPeriod[msg.sender] = block.timestamp;

        // 4.- Transfer rewards
        (bool success, ) = msg.sender.call{value: rewardPerPeriod}("");
        require(success, "Transfer failed.");
    }

    // function feedContract() external payable onlyOwner {}
    receive() external payable onlyOwner {
        emit EtherSent(msg.value);
    }
    

    function changeStakingPeriod(uint256 stakingPeriod_) external onlyOwner {
        stakingPeriod = stakingPeriod_;
        emit ChangeStakingPeriod(stakingPeriod_);
    }
}