// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./DiscretionaryPool.sol";
import "./Presale.sol";

contract TapControlledToken {
    address public owner;
    Presale public presale;     //Presale contract is acting as marketMaker also
    DiscretionaryPool public discretionaryPool;   // a new contract to contain tap amount
    // address public beneficiary;       //    
    uint256 public tapRate; // Amount of funds that can be withdrawn per time period
    uint256 public tapPeriod; // Time period in seconds
    // uint public reserveFloor; // Minimum balance required in the market-maker pool
    uint256 public availableFunds;
    // uint256 public numOfCurrentPeriod;  //

    uint256 public lastWithdrawalTimestamp;
    // uint256 public lastWithdrawalAmount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor(
        Presale _presale,
        DiscretionaryPool _discretionaryPool,
        // address _beneficiary,
        uint256 _tapRate,
        uint256 _tapPeriod,
        uint256 _availableFunds
        // uint256 _numOfPeriods;
        // uint _reserveFloor
    ) {
        owner = msg.sender;
        presale = _presale;
        discretionaryPool = _discretionaryPool;
        // beneficiary = _beneficiary;
        tapRate = _tapRate;
        tapPeriod = _tapPeriod;
        // reserveFloor = _reserveFloor;
        availableFunds = _availableFunds;
        // numOfPeriods = _numOfPeriods;
        lastWithdrawalTimestamp = block.timestamp;
    }

    function withdraw() external onlyOwner {
        uint256 elapsedTime = block.timestamp - lastWithdrawalTimestamp;
        // uint availableFunds = (elapsedTime * tapRate) - lastWithdrawalAmount;

        // if (availableFunds > address(this).balance - reserveFloor) {
        //     availableFunds = address(this).balance - reserveFloor;
        // }
        require( elapsedTime >= tapPeriod,"It is a bit early to take out your funds" );
        require(availableFunds > 0, "No funds available for withdrawal.");

        uint256 transferableBalance;
        if ( availableFunds <= tapRate ){
            transferableBalance = availableFunds;
        }
        else{
            transferableBalance = tapRate;
        }
        discretionaryPool.callPresaleToReceive(presale,transferableBalance);
        availableFunds -=transferableBalance;

        lastWithdrawalTimestamp = block.timestamp;
        // lastWithdrawalAmount += availableFunds;



        // Transfer funds from the market-maker pool to the discretionary pool
        
        // (bool success, ) = marketMakerPool.call{value: availableFunds}("");
        // require(success, "Transfer to the discretionary pool failed.");
    }


    function close() external onlyOwner {
        selfdestruct(payable(owner));
    }
}
