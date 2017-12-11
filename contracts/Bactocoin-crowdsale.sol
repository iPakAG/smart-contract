pragma solidity 0.4.17;

contract BactocoinCrowsale is Ownable {
    using SafeMath for uint256;

    uint256 public constant startTime = 1513256400; // 14.12.2017 14:00:00 GMT(+1)
    uint256 public constant endTime = 1514069999; // 23.12.2017, 23:59:59 GMT(+1)
    uint256 public constant bonusTime = 6000; // in seconds, 100 minutes
    address public constant wallet = 0xf00d4ec8af332b0a5a9eb24bfce32cf158ab6a4a;
    uint256 public constant chfCentsPerToken = 2500; // CHF 25.00
    uint256 public constant chfCentsPerTokenWhileBonus = 1875; // CHF 18.75
    uint256 public chfCentsPerEth = 30000; // CHF 300,00
    uint256 public weiRaised;


    BactocoinToken public token;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function BactocoinCrowsale() Ownable() {

        require(startTime >= now);
        require(endTime >= startTime);
        require(wallet != address(0));

        token = new BactocoinToken(this);
        // we pass address of this contract, as this cont will tranfer funds to buyers
    }

    function convertWeiToTokens(uint256 weiAmount) view returns (uint256) {
        uint256 chfCentsAmount = weiAmount;
        chfCentsAmount *= chfCentsPerEth;
        uint256 tokensAmountSatoshi = (chfCentsAmount / (chfCentsPerToken));
        if (bonusInEffect()) {
            tokensAmountSatoshi = (chfCentsAmount / (chfCentsPerTokenWhileBonus));
        }
        return tokensAmountSatoshi;
    }


    // fallback function can be used to buy tokens
    function () payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase());

        uint256 tokensAmountSatoshi = convertWeiToTokens(msg.value);

        require(tokensAmountSatoshi <= token.balanceOf(this)); // not enough tokens left ?
        token.transfer(beneficiary, tokensAmountSatoshi);
        TokenPurchase(msg.sender, beneficiary, msg.value, tokensAmountSatoshi);
        weiRaised = weiRaised.add(msg.value);

        forwardFunds();
    }

    function updateChfCentsPerEth(uint256 newCents) onlyOwner {
        chfCentsPerEth = newCents;
    }

    // after crowdsale ends this method withdraws all unsold tokens
    function allocateAllUnsoldTokens(address newOwner) onlyOwner {
        require(token.balanceOf(this) > 0);
        require(hasEnded());
        token.transfer(newOwner, token.balanceOf(this));
    }

    // tokens bought with BTC are sent via this method
    function giveTokens(address newOwner, uint256 amount) onlyOwner {
        require(token.balanceOf(this) >= amount);
        token.transfer(newOwner, amount);
    }

    // send ether to the fund collection wallet
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }


    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    function bonusInEffect() internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= (startTime + bonusTime);
        return withinPeriod;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        return now > endTime;
    }

}
