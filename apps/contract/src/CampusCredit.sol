// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title CampusCredit
 * @dev ERC-20 token untuk transaksi dalam kampus
 * Use cases:
 * - Pembayaran di kafetaria
 * - Biaya printing dan fotokopi
 * - Laundry service
 * - Peminjaman equipment
 */
contract CampusCredit is ERC20, ERC20Burnable, Pausable, AccessControl {
    error NotPauserRole();
    error SurpassedMintingLimit();
    error MerchantIsRegistered();
    error MerchantIsNotRegistered();
    error MerchantNameIsEmpty();
    error TransferSurpassDailySpendingLimit();
    error ContractIsPaused();

    // TODO: Define role constants
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint32 public constant INITIAL_MINT_AMOUNT = 1_000_000;
    uint32 public constant MINTING_LIMIT = 10_000;
    
    // Additional features untuk kampus
    mapping(address => uint256) public dailySpendingLimit;
    mapping(address => uint256) public spentToday;
    mapping(address => uint256) public lastSpendingReset;
    
    // Merchant whitelist
    mapping(address => bool) public isMerchant;
    mapping(address => string) public merchantName;

    constructor() ERC20("Campus Credit", "CREDIT") {
        // TODO: Setup roles
        // Hint:
        // 1. Grant DEFAULT_ADMIN_ROLE ke msg.sender
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // 2. Grant PAUSER_ROLE ke msg.sender
        _grantRole(PAUSER_ROLE, msg.sender);
        // 3. Grant MINTER_ROLE ke msg.sender
        _grantRole(MINTER_ROLE, msg.sender);
        // 4. Consider initial mint untuk treasury
        _mint(msg.sender, INITIAL_MINT_AMOUNT);
    }

    /**
     * @dev Pause all token transfers
     * Use case: Emergency atau maintenance
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        // TODO: Implement dengan role check
        // Only PAUSER_ROLE can pause
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        // TODO: Implement unpause
        _unpause();
    }

    /**
     * @dev Mint new tokens
     * Use case: Top-up saldo mahasiswa
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        // TODO: Implement dengan role check
        // Only MINTER_ROLE can mint
        // Consider adding minting limits
        if (amount > MINTING_LIMIT) {
            revert SurpassedMintingLimit();
        }

        _mint(to, amount);
    }

    /**
     * @dev Register merchant
     * Use case: Kafetaria, toko buku, laundry
     */
    function registerMerchant(address merchant, string memory name) 
        public onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        // TODO: Register merchant untuk accept payments
        /*
        mapping(address => bool) public isMerchant;
        mapping(address => string) public merchantName;
        */
        if (isMerchant[merchant]) {
            revert MerchantIsRegistered();
        }

        if (bytes(name).length == 0) {
            revert MerchantNameIsEmpty();
        }

        isMerchant[merchant] = true;
        merchantName[merchant] = name;
    }

    /**
     * @dev Set daily spending limit untuk mahasiswa
     * Use case: Parental control atau self-control
     */
    function setDailyLimit(address student, uint256 limit) 
        public onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        // TODO: Set spending limit
        dailySpendingLimit[student] = limit;
    }

    /**
     * @dev Transfer dengan spending limit check
     */
    function transferWithLimit(address to, uint256 amount) public {
        // TODO: Check daily limit before transfer
        uint256 _userDailyLimit = dailySpendingLimit[msg.sender];
        uint256 _userLastSpendingReset = lastSpendingReset[msg.sender];
        if (amount > _userDailyLimit) {
            revert TransferSurpassDailySpendingLimit();
        }
        // Reset limit if new day
        /* state
        mapping(address => uint256) public spentToday;
        mapping(address => uint256) public lastSpendingReset; 
        */
        uint256 _timestampNow = block.timestamp;
        uint256 _userSpending = spentToday[msg.sender];
        if (_timestampNow > _userLastSpendingReset + 1 days) {
            lastSpendingReset[msg.sender] = _timestampNow;
            _userSpending = 0;
        }
        // Update spent amount
        _userSpending += amount;
        spentToday[msg.sender] = _userSpending;
        // Then do normal transfer
        _transfer(msg.sender, to, amount);
    }

    /**
     * @dev Override _beforeTokenTransfer untuk add pause functionality
     */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) {
        // TODO: Add pause check
        if (paused()) {
            revert ContractIsPaused();
        }
        // super._beforeTokenTransfer(from, to, amount);
        super._update(from, to, amount);
        // require(!paused(), "Token transfers paused");

    }

    /**
     * @dev Cashback mechanism untuk encourage usage
     */
    uint256 public cashbackPercentage = 2; // 2%
    
    function transferWithCashback(address merchant, uint256 amount) public {
        // TODO: Transfer to merchant dengan cashback ke sender
        if (isMerchant[merchant]) {
            revert MerchantIsNotRegistered();
        }
        // Calculate cashback
        uint256 cashbackAmount = (amount / 100) * 2;
        // Transfer main amount
        transferFrom(msg.sender, merchant, amount);
        // Mint cashback to sender
        _mint(msg.sender, cashbackAmount);
    }
}