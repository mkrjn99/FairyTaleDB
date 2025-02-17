// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PDHWToken {
    bool public paused = false;
    string public name = "PDHWToken";
    string public symbol = "PDHW";
    uint8 public decimals = 6;
    uint256 public ltcr_inr = 8;
    uint256 public pending_payments_inr = 51 * 1e5;
    uint256 public transaction_fee = 1000000;
    uint256 public ownership_transfer_price = 72 ether;
    uint128 public num_negative_balance_addresses = 0;
    int256 public negative_balance_limit = - 10000 * 1000000;

    address public owner;
    address public pending_payments_wallet_id;
    mapping(address => int256) public balances;
    mapping(address => bool) public negative_balance_allowed;
    mapping(address => bool) public blacklisted;
    mapping(address => mapping(address => uint256)) public allowances;
    mapping(address => uint256) public pendingWithdrawals;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event LtcrInrUpdated(uint256 newValue);
    event BalanceUpdated(address indexed wallet, int256 newBalance);
    event NegativeBalanceAllowed(address indexed wallet);
    event NegativeBalanceDisallowed(address indexed wallet);
    event WalletBlacklisted(address indexed wallet);
    event TransferOwnership(address indexed from, address indexed to, uint256 value);

    bool public is_set_balance_allowed = true;
    bool public is_set_ltcr_inr_allowed = true;
    bool public is_negative_balance_allowance_allowed = true;

    modifier onlyEOA() {
        require(tx.origin == msg.sender, "Smart contracts cannot own this token");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier isSetBalanceAllowed() {
        require(is_set_balance_allowed, "Setting balance isn't allowed anymore");
        _;
    }

    modifier isSetLtcrInrAllowed() {
        require(is_set_ltcr_inr_allowed, "Setting LTCR INR isn't allowed anymore");
        _;
    }

    modifier isNegativeBalanceAllowanceAllowed() {
        require(is_negative_balance_allowance_allowed, "Allowing new negative balance wallets isn't allowed anymore");
        _;
    }

    modifier onlyWallet(address from) {
        require(msg.sender == from, "Only wallet owner can call this function");
        _;
    }

    modifier notBlacklisted(address wallet) {
        require(!blacklisted[wallet], "Wallet is blacklisted");
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

    function setLtcrInr(uint256 val) external onlyOwner isSetLtcrInrAllowed {
        ltcr_inr = val;
        balances[pending_payments_wallet_id] = truncateUint256ToInt128((pending_payments_inr * decimals)/ ltcr_inr);
        emit BalanceUpdated(pending_payments_wallet_id, balances[pending_payments_wallet_id]);
        emit LtcrInrUpdated(val);
    }

    function setBalance(address wallet_id, int256 balance) external onlyOwner isSetBalanceAllowed {
        require(wallet_id != pending_payments_wallet_id, "Cannot set balance for pending payments wallet");
        balances[wallet_id] = balance;
        emit BalanceUpdated(wallet_id, balance);
    }

    function allowNegativeBalance(address wallet_id) external onlyOwner isNegativeBalanceAllowanceAllowed {
        assert(wallet_id != owner);
        if (negative_balance_allowed[wallet_id]) {
            return;
        }
        ++num_negative_balance_addresses;
        negative_balance_allowed[wallet_id] = true;
        emit NegativeBalanceAllowed(wallet_id);
    }

    function disallowNegativeBalance(address wallet_id) external onlyOwner  {
        if (!negative_balance_allowed[wallet_id]) {
            return;
        }
        --num_negative_balance_addresses;
        negative_balance_allowed[wallet_id] = false;
        emit NegativeBalanceDisallowed(wallet_id);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address from, address to, uint256 amount) external onlyWallet(from) notBlacklisted(from) notBlacklisted(to) {
        require(balances[from] - int256(amount + transaction_fee) >= negative_balance_limit, "Insufficient balance");
        balances[from] -= int256(amount + transaction_fee);
        balances[owner] += int256(transaction_fee);
        balances[to] += int256(amount);
        emit BalanceUpdated(from, balances[from]);
        emit BalanceUpdated(owner, balances[owner]);
        emit BalanceUpdated(to, balances[to]);
        emit Transfer(from, to, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external notBlacklisted(sender) notBlacklisted(recipient) returns (bool) {
        require(balances[sender] > 0, "transferFrom should be called by positive balance holders only");
        require(int256(amount) <= balances[sender], "Insufficient balance");
        require(amount <= allowances[sender][msg.sender], "Allowance exceeded");

        balances[sender] -= int256(amount + 2 * transaction_fee);
        balances[owner] += int256(2 * transaction_fee);
        balances[recipient] += int256(amount);
        allowances[sender][msg.sender] -= amount;

        emit BalanceUpdated(sender, balances[sender]);
        emit BalanceUpdated(owner, balances[owner]);
        emit BalanceUpdated(recipient, balances[recipient]);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function blacklistWalletId(address wallet_id)  external onlyOwner {
        balances[wallet_id] = 0;
        blacklisted[wallet_id] = true;
        emit BalanceUpdated(wallet_id, 0);
        emit WalletBlacklisted(wallet_id);
    }

    function renounceSetBalanceRights() external onlyOwner {
        is_set_balance_allowed = false;
    }

    function renounceSetLtcrInrRights() external onlyOwner {
        is_set_ltcr_inr_allowed = false;
    }

    function renounceNegativeBalanceAllowanceRights() external onlyOwner {
        is_negative_balance_allowance_allowed = false;
    }

    function burn() external onlyOwner {
        uint256 burnt_amount = uint256(balances[owner]) / (ltcr_inr * decimals);
        require(burnt_amount <= pending_payments_inr, "Burnt amount should always be less than current tokens");
        pending_payments_inr -= burnt_amount;
        balances[owner] = 0;
        emit BalanceUpdated(owner, 0);
    }

    function setOwnershipPrice(uint8 value) external onlyOwner {
        ownership_transfer_price = value * 1 ether;
    }

    function buyOwnership() external onlyEOA payable {
        require(msg.value == ownership_transfer_price, "Incorrect payment amount!");

        address previousOwner = owner;
        owner = msg.sender;

        emit TransferOwnership(previousOwner, msg.sender, msg.value);

        // Store the amount instead of sending it immediately
        pendingWithdrawals[previousOwner] += msg.value;
    }

    function withdraw() external onlyEOA {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No funds to withdraw");

        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function transferOwnership(address _owner) external onlyOwner {
        owner = _owner;
        emit TransferOwnership(_owner, msg.sender, 0);
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }
}
