/**
 * Overflow aware uint math functions.
 *
 * Inspired by https://github.com/MakerDAO/maker-otc/blob/master/contracts/simple_market.sol
 */
pragma solidity ^0.4.2;

contract SafeMath {
  //internals

  function safeMul(int a, int b) internal returns (int) {
    int c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(int a, int b) internal returns (int) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(int a, int b) internal returns (int) {
    int c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

/**
 * ERC 20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 */
contract Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (int supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (int balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, int _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, int _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, int _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (int remaining) {}

    event Transfer(address indexed _from, address indexed _to, int _value);
    event Approval(address indexed _owner, address indexed _spender, int _value);

}

/**
 * ERC 20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is Token {

    /**
     * Reviewed:
     * - Interger overflow = OK, checked
     */
    function transfer(address _to, int256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        //if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, int256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (int256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, int256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (int256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping(address => int) balances;

    mapping (address => mapping (address => int256)) allowed;

    int256 public totalSupply;

}


/**
 * PolyCoinss crowdsale crowdsale contract.
 *
 */
contract PolyCoins is StandardToken,SafeMath {

    uint startBlock; //crowdsale start block (set in constructor)
    uint endBlock; //crowdsale end block (set in constructor)

    int a;
    int b;
    int c;
    int d;
    int e;
    int f;

    uint cap;   

    address public owner = 0x0;

    event Buy(address indexed sender, uint eth, uint fbt);

    function PolyCoins(int _a, int _b, int _c,int _d,int _e,int _f,int cap) {
        owner = msg.sender;
        startBlock = block.number;
        endBlock = startBlock + 19378; // 3.14 days
        a = _a;
        b = _b;
        c = _c;
        d = _d;
        e = _e;
        f = _f;
    }

   
    function price() constant returns(int) {
        return testPrice(block.number-(startBlock+19378)/2);        
    }

    // price() exposed for unit tests
    function testPrice(uint _blockNumber) constant returns(int) {
        uint blockNumber = _blockNumber;
        if (blockNumber<startBlock || blockNumber>endBlock) return 0; // inactive
        int tmp = a*blockNumber*blockNumber*blockNumber*blockNumber*blockNumber + b*blockNumber*blockNumber*blockNumber*blockNumber + c*blockNumber*blockNumber*blockNumber + d*blockNumber*blockNumber + e*blockNumber + f;
        if (tmp<0){
            tmp = tmp * -1;
        }
        return tmp;
    }

    /**
     * Direct deposits buys tokens
     */
    function() payable {
        if (block.number<startBlock || block.number>endBlock) throw;
        int polyval = safeMul(msg.value, price());
        balances[msg.sender] = safeAdd(balances[msg.sender],polyval );
        totalSupply = safeAdd(totalSupply, polyval);

        Buy(msg.sender, msg.value,polyval );
    }

}