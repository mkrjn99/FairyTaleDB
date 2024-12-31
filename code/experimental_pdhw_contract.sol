// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for the ERC20 token (USDC)
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

// PDHW Token contract
contract PDHW {
    // Variables
    string public name = "PDHW Token";
    string public symbol = "PDHW";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;
    mapping(address => uint256) public balanceOf;
    
    // Address of the USDC token contract
    address public usdcAddress = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48;  // USDC contract address

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);

    // Constructor to set initial values
    constructor() {
        owner = msg.sender;
        totalSupply = 50 * 10**6 * 10**18; // 50M PDHW tokens with 18 decimals
        balanceOf[owner] = totalSupply;
    }

    // Function to mint PDHW tokens and transfer them to the sender
    function mintPDHW(uint256 usdcAmount) external {
        require(usdcAmount > 0, "Amount must be greater than zero");

        // Calculate the PDHW tokens to mint (10x the USDC amount)
        uint256 pdhwAmount = usdcAmount * 10;

        // Ensure that the contract has enough PDHW tokens to mint
        require(balanceOf[owner] >= pdhwAmount, "Not enough PDHW tokens in the contract");

        // Transfer USDC from sender to this contract
        IERC20(usdcAddress).transferFrom(msg.sender, address(this), usdcAmount);

        // Transfer the equivalent PDHW tokens to the sender
        balanceOf[owner] -= pdhwAmount; // Reduce the owner's balance
        balanceOf[msg.sender] += pdhwAmount; // Add the PDHW to the sender's balance

        // Emit transfer and mint events
        emit Transfer(owner, msg.sender, pdhwAmount);
        emit Mint(msg.sender, pdhwAmount);

        // Transfer the received USDC to the deployer's address (owner)
        IERC20(usdcAddress).transfer(owner, usdcAmount);
    }

    // Internal function to handle transfers
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Transfer to the zero address");
        require(balanceOf[from] >= value, "Insufficient balance");

        balanceOf[from] -= value;
        balanceOf[to] += value;

        emit Transfer(from, to, value);
    }
}
