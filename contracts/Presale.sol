// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Token.sol";
import "./DiscretionaryPool.sol";

contract Presale{       //Presale contract-> discretionaryPool(timely) -> benificiary       (amount)
    Token public token;
    address public beneficiary;
    DiscretionaryPool public discretionaryPool;   //
    uint256 public rate;
    uint256 public goal;
    uint256 public raisedAmount;
    mapping(address => uint256) public contributions;
    bool public goalReached;
    bool public presaleClosed;

    event GoalReached(uint256 amountRaised);
    event FundTransfer(address backer, uint256 amount);

    constructor(
        Token _token,
        address _beneficiary,
        DiscretionaryPool _discretionaryPool,
        uint256 _rate,
        uint256 _goal
    ) {
        token = _token;
        beneficiary = _beneficiary;
        discretionaryPool = _discretionaryPool;
        rate = _rate;
        goal = _goal;
        raisedAmount = 0;
        goalReached = false;
        presaleClosed = false;
    }

    modifier onlyWhileOpen() {
        require(!presaleClosed, "Presale has already ended");
        _;
    }

    function contribute() public payable onlyWhileOpen {
        require(msg.value > 0, "Contribution amount must be greater than 0");

        contributions[msg.sender] += msg.value;
        raisedAmount += msg.value;

        token.transfer(msg.sender,msg.value*rate);
        // Transfer tokens to the contributor
        // Assuming the token has a transferFrom() function
        // and the presale contract has been approved to spend the tokens
        // You need to implement the token contract separately
        // and handle token transfers according to your token implementation
        // token.transferFrom(beneficiary, msg.sender, msg.value * rate);

        emit FundTransfer(msg.sender, msg.value);

        checkGoalReached();
    }

    function checkGoalReached() internal {
        if (raisedAmount >= goal && !goalReached) {
            goalReached = true;
            emit GoalReached(raisedAmount);
        }
    }

    function closePresale() public {
        require(!presaleClosed, "Presale has already been closed");
        require(msg.sender == beneficiary, "Only the beneficiary can close the presale");

        presaleClosed = true;
    }

    // function withdrawTokens() public {
    //     require(presaleClosed, "Presale has not yet been closed");
    //     require(msg.sender == beneficiary, "Only the beneficiary can withdraw tokens");

    //     token.transfer(beneficiary, token.balanceOf(address(this)));
    // }

    function withdrawGoalAmount( uint amount ) public {
        require(presaleClosed, "Presale has not yet been closed");
        require(msg.sender == address(discretionaryPool), "Only the discretionaryPool can withdraw amount");
        require(amount <= address(this).balance, "Sufficient balance not available");
        // payable(discretionaryPool).transfer(address(this).balance);
        (bool success, ) = address(discretionaryPool).call{value: amount}("");
        require(success, "Transfer to the discretionary pool failed.");
    } 
}
