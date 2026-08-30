// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity 0.8.24;

/*

    Functions:
        1.- Deposit ether
        2.- Withdraw ether
    
    Rules:
        1.- Multi-user bank
        2.- Only can deposit ether
        3.- User can only withdraw previously deposited ether
        4.- Max balance per user = 5 ether
        5.- MaxBalance modifiable by owner

        userA => Deposit (5 ether)
        userB => Deposit (2 ether)
        Bank balance => 7 ether

        userA => Deposit (1 ether) => Deposit (5 ether) => Withdraw (2 ether) => Withdraw (4 ether)

*/

contract CryptoBank {

    uint256 public maxBalance;
    address public owner;
    mapping(address => uint256) public userBalances;

    event EtherDeposit(address user_, uint256 etherAmount_);
    event EtherWithdraw(address user_, uint256 etherAmount_);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not allowed.");
        _;
    }

    constructor(uint256 maxBalance_, address owner_) {
        maxBalance = maxBalance_;
        owner = owner_;
    }

    // Functions
    // 1. deposit
    function depositEther() external payable {
        require(msg.value + userBalances[msg.sender] <= maxBalance, "Max ether reached.");
        userBalances[msg.sender] += msg.value;
        emit EtherDeposit(msg.sender, msg.value);
    }

    // 2. withdraw
    function withdrawEther(uint256 amount_) external {

        // CEI pattern : 
        // 1.- Checks
        // 2.- Effects (update state)
        // 3.- Interactions
        // => The order of the steps it's important to avoid Reentrancy attacks!

        require(userBalances[msg.sender] >= amount_, "Not enough ether.");

        // 1.- update balance
        userBalances[msg.sender] -= amount_;

        // 2.- transfer ether
        (bool success, ) = msg.sender.call{value: amount_}("");
        require(success, "Transfer failed.");

        emit EtherWithdraw(msg.sender, amount_);
    }

    // 3. modify maxBalance
    function modifyMaxBalance(uint256 maxBalance_) external onlyOwner {
        maxBalance = maxBalance_;
    }
}
