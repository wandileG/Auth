// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract WatchInsurance {
    //the addresses that took a policy, in an array
    address [] public policyholders;
    //a mapping that keeps the policy (unique id) taken by the address
    mapping(address => uint256) public policies;
    //a mapping keeps track of how many claims an address filed
    mapping(address => uint256) public claims;
    //the address/vendor issuing the contract
    address payable provider;
    //total active plans
    uint256 public totalPremium;
    
    //constructor to set the address deploying the contract is the owner of the contract
    constructor() {
        provider = payable(msg.sender);
    }

    function purchasePolicy(uint256 premium) public payable {
        require(msg.value == premium, "Incorrect premium amount.");
        require(premium > 0, "Premium amount must be greater than 0.");
        policyholders.push(msg.sender);
        policies[msg.sender] = premium;
        totalPremium += premium;
    }

    function fileclaim(uint256 amount) public {
        require(policies[msg.sender] > 0, "Must have an active policy to file a claim!");
        require(amount > 0, "Claim amount must be greater than 0.");
        require(amount <= policies[msg.sender], "Claim amount cannot exceed policy!");
        claims[msg.sender] +=amount;
    }

    function approveClaim(address policyholder) public {
        require(msg.sender == provider, "Only the provider can approve claims.");
        require(claims[policyholder] > 0, "Policyholder has no outstanding claims.");
        payable (policyholder).transfer(claims[policyholder]);
        claims[policyholder] = 0;
    }

    function getPolicy(address policyholder) public view returns (uint256) {
        return policies[policyholder];
    }

    function getClaim(address policyholder) public view returns (uint256) {
        return claims [policyholder];
    }

    function getTotalPremium() public view returns (uint256){
        return totalPremium;
    }

    function grantAccess(address payable user) public {
        require(msg.sender == provider, "Only the owner can grant access.");
        provider = user;
    }

    function revokeAccess(address payable user) public {
        require(msg.sender == provider, "Only owner can revoke access."); 
        require(user != provider, "Cannot revoke access for the current owner.");
        provider = payable(msg.sender);
    }

    function destroy() public {
        require(msg.sender == provider, "Only owner can destroy the contract.");
        selfdestruct(provider);
    }
}
