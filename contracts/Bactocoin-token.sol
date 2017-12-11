pragma solidity 0.4.17;

contract BactocoinToken is StandardToken {
    string public name = 'BactoCoin';
    uint8 public decimals = 18;
    string public symbol = 'BTNN';
    string public version = '1.0.0';
    uint256 public totalSupply = 4e24 ; // 4 mil
    address public originalTokenHolder;

    function BactocoinToken(address allTokensHolder) {
        originalTokenHolder = allTokensHolder ;
        balances[allTokensHolder] = totalSupply; // Give the creator all initial tokens
        Transfer(0x0, allTokensHolder, totalSupply);
    }

}

