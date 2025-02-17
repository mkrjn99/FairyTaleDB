// Semi-auto-generated code: https://chatgpt.com/c/67b29926-32b8-8004-8bd4-eba71198078f
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PDHWToken {
    string public name = "PDHWToken";
    string public symbol = "PDHW";
    uint8 public decimals = 6;
    uint256 public ltcr_inr = 6000000;
    uint256 public pending_payments = 51 * 1e5;
    uint256 public transaction_fee = 1000000;

    address public owner;
    address public pending_payments_wallet_id;
    mapping(address => int256) public balances;
    mapping(address => bool) public negative_balance_allowed;
    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event LtcrInrUpdated(uint256 newValue);
    event BalanceUpdated(address indexed wallet, int256 newBalance);
    event NegativeBalanceAllowed(address indexed wallet);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyWallet(address from) {
        require(msg.sender == from, "Only wallet owner can call this function");
        _;
    }

    constructor(address _pending_payments_wallet_id) {
        owner = msg.sender;
        pending_payments_wallet_id = _pending_payments_wallet_id;
    }

    function truncateUint256ToInt128(uint256 input) public pure returns (int128) {
        input &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        require(input >= 0, "truncated int128 value should be positive");
        return int128(int256(input));
    }

    function setLtcrInr(uint256 val) external onlyOwner {
        ltcr_inr = val;
        balances[pending_payments_wallet_id] = truncateUint256ToInt128(pending_payments / ltcr_inr);
        emit LtcrInrUpdated(val);
    }

    function setBalance(address wallet_id, int256 balance) external onlyOwner {
        require(wallet_id != pending_payments_wallet_id, "Cannot set balance for pending payments wallet");
        balances[wallet_id] = balance;
        emit BalanceUpdated(wallet_id, balance);
    }

    function transfer(address from, address to, uint256 amount) external onlyWallet(from) {
        require(
            negative_balance_allowed[from] || (amount + transaction_fee) <= uint256(balances[from]),
            "Insufficient balance or negative balance not allowed"
        );
        balances[from] -= int256(amount + transaction_fee);
        balances[to] += int256(amount);
        emit Transfer(from, to, amount);
    }

    function allowNegativeBalance(address wallet_id) external onlyOwner {
        negative_balance_allowed[wallet_id] = true;
        emit NegativeBalanceAllowed(wallet_id);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(balances[sender] > 0, "transferFrom should be called by positive balance holders only");
        require(int256(amount) <= balances[sender], "Insufficient balance");
        require(amount <= allowances[sender][msg.sender], "Allowance exceeded");

        balances[sender] -= int256(amount);
        balances[recipient] += int256(amount);
        allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }
}
