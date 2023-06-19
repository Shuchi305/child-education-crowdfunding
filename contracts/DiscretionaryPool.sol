// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Presale.sol";

contract DiscretionaryPool {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    function withdraw() external {
        require(msg.sender == owner, "Only the contract owner can call this function");
        require(address(this).balance > 0, "Contract balance is zero");

        uint256 contractBalance = address(this).balance;
        owner.transfer(contractBalance);
    }
    function callPresaleToReceive (Presale _presale,uint256 amount) public{
        _presale.withdrawGoalAmount(amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
