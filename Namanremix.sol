// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DynamicPricingToken {
    // Token details
    string public name = "DynamicPriceToken";
    string public symbol = "DPT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // Balances of each address
    mapping(address => uint256) public balanceOf;

    // Dynamic pricing variables
    uint256 public basePrice = 1 ether; // Base price for 1 token
    uint256 public volumeThreshold = 1000 * 10**decimals; // Volume threshold for price adjustment
    uint256 public priceIncreaseFactor = 2; // Price increases by this factor after threshold

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 totalCost);

    // Transfer tokens from one address to another
    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    // Buy tokens with dynamic pricing
    function buyTokens() public payable {
        uint256 amountToBuy = calculateTokenAmount(msg.value);
        require(amountToBuy > 0, "Insufficient payment");

        // Update total supply and buyer's balance
        totalSupply += amountToBuy;
        balanceOf[msg.sender] += amountToBuy;

        emit Transfer(address(0), msg.sender, amountToBuy);
        emit TokensPurchased(msg.sender, amountToBuy, msg.value);
    }

    // Calculate the amount of tokens to buy based on dynamic pricing
    function calculateTokenAmount(uint256 payment) public view returns (uint256) {
        uint256 currentPrice = basePrice;
        uint256 remainingPayment = payment;
        uint256 totalTokens = 0;

        // Calculate tokens based on dynamic pricing
        while (remainingPayment >= currentPrice) {
            uint256 tokensAtCurrentPrice = remainingPayment / currentPrice;
            totalTokens += tokensAtCurrentPrice;
            remainingPayment -= tokensAtCurrentPrice * currentPrice;

            // Adjust price if volume threshold is exceeded
            if (totalSupply + totalTokens >= volumeThreshold) {
                currentPrice *= priceIncreaseFactor;
            }
        }

        return totalTokens;
    }

    // Fallback function to accept Ether
    receive() external payable {
        buyTokens();
    }
}
