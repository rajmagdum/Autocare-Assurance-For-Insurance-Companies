//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//Import necessary Chainlink contracts
import {Chainlink, ChainlinkClient} from "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract MultiWordConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request; //Chainlink Library

    //variable to store Chainlink Job ID and fee
    bytes32 private jobId;
    uint256 private fee;


    // variables to store the required output data
    uint256 public vehicleid;
    uint256 public enginehealth;
    uint256 public timestamp;

    //Event emitted when the request is fulfilled
    /**
     * @param requestId The ID of the request
     * @param btc The vehicle ID
     * @param usd The engine health
     * @param eur The timestamp
     */
    event RequestMultipleFulfilled(
        bytes32 indexed requestId,
        uint256 btc,
        uint256 usd,
        uint256 eur
    );

    // Constructor function to set up the contract
    constructor() ConfirmedOwner(msg.sender) {
        _setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789); //set the chainlink token address for LINK
        _setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD); //set the chainlnk oracle address for sepholia testnet
        jobId = "53f9755920cd451a8fe46f5087468395"; //set the Chainlink jobID
        fee = (1 * LINK_DIVISIBILITY) / 10; // Fee in LINK 0,1 * 10**18 (Varies by network and job)
    }

    //Function for Chainlink Request
    function requestMultipleParameters() public {
        Chainlink.Request memory req = _buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillMultipleParameters.selector
        );
        // Add the API URL and paths
        req._add(
            "urlBTC",
            "https://insurancefinal.onrender.com/result"
        );
        req._add("pathBTC", "data,VEHICLEID");
        req._add(
            "urlUSD",
            "https://insurancefinal.onrender.com/result"
        );
        req._add("pathUSD", "data,ENGINEHEALTH");
        req._add(
            "urlEUR",
            "https://insurancefinal.onrender.com/result"
        );
        req._add("pathEUR", "data,TIMESTAMP");
        _sendChainlinkRequest(req, fee); // MWR API.
    }

    //Function to fulfill the request called by Chainlink
    function fulfillMultipleParameters(
        bytes32 requestId,
        uint256 btcResponse,
        uint256 usdResponse,
        uint256 eurResponse
    ) public recordChainlinkFulfillment(requestId) {
        // Emit the event
        emit RequestMultipleFulfilled(
            requestId,
            btcResponse,
            usdResponse,
            eurResponse
        );

        //Storing the response in the contract variables
        vehicleid = btcResponse;
        enginehealth = usdResponse;
        timestamp = eurResponse;
    }

    // Function to return data to the frontend
    function getInsuranceDetails() public view returns (uint256, uint256, uint256, uint256) {
        uint256 insurancePremium = 50;
        //Calculate the insurance premium based on the engine health
        if (enginehealth == 100000) {
            insurancePremium = (insurancePremium * 95) / 100;
        }
        return (vehicleid, enginehealth, timestamp, insurancePremium);
    }

    // Function to withdraw LINK tokens fro the contract
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(_chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
