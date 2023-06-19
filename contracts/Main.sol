// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Presale.sol";

contract Main {
    struct Campaign {
        uint256 id;
        address creator;
        string name;
        string description;
        uint256 fundingGoal;
        uint256 currentFunding;
        uint256 totalDuration;  //
        uint256 periods;    //
        bool active;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public totalCampaigns;

    event CampaignCreated(uint256 indexed id, address indexed creator, string name);
    event FundsContributed(uint256 indexed id, address indexed contributor, uint256 amount);
    event FundingGoalReached(uint256 indexed id, uint256 amount);

    Presale public presale;

    function createCampaign(string memory _name, string memory _description, uint256 _fundingGoal, uint256 _totalDuration , uint256 _periods, 
                            Presale _presale) external 
    {
        totalCampaigns++;
        Campaign storage newCampaign = campaigns[totalCampaigns];
        newCampaign.id = totalCampaigns;
        newCampaign.creator = msg.sender;
        newCampaign.name = _name;
        newCampaign.description = _description;
        newCampaign.fundingGoal = _fundingGoal;
        newCampaign.totalDuration = _totalDuration;
        newCampaign.periods = _periods;
        newCampaign.active = true;
        presale = _presale;

        emit CampaignCreated(totalCampaigns, msg.sender, _name);
    }

    function contributeFunds(uint256 _campaignId) external payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(campaign.active, "Campaign is not active yet");
        require(campaign.currentFunding < campaign.fundingGoal, "Campaign has already finished.");

        campaign.currentFunding += msg.value;

        emit FundsContributed(_campaignId, msg.sender, msg.value);

        if (campaign.currentFunding >= campaign.fundingGoal) {
            campaign.active = false;
            emit FundingGoalReached(_campaignId, campaign.currentFunding);
        }
    }

    function getCampaign(uint256 _campaignId) external view returns (
        uint256 id,
        address creator,
        string memory name,
        string memory description,
        uint256 fundingGoal,
        uint256 currentFunding,
        bool active
    ) {
        Campaign memory campaign = campaigns[_campaignId];
        return (
            campaign.id,
            campaign.creator,
            campaign.name,
            campaign.description,
            campaign.fundingGoal,
            campaign.currentFunding,
            campaign.active
        );
    }
}
