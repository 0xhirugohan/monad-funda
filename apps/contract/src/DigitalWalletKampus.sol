// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract DigitalWalletKampus {
    mapping(address => uint256) public balances;
    address public admin;
    mapping(address => bool) public withdrawApproval;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approve(address indexed user, bool isApproved);

    error Error_NotAdmin();
    error Error_NotEnoughApproval();
    error Error_BalanceNotEnough();
    error Error_ValueIsZero();
    error Error_TransferFail();
    error Error_TransferIsZero();
    error Error_ToIsSender();

    constructor() {
        admin = msg.sender;
    }

    function deposit() public payable {
        require(msg.value > 0, "Amount harus lebih dari 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // TODO: Implementasi withdraw function
    function withdrawal(uint256 value) public {
        require(withdrawApproval[msg.sender] == true, "Error_NotEnoughApproval");
        require(balances[msg.sender] >= value, "Error_BalanceNotEnough");
        require(value > 0, "Error_ValueIsZero");

        withdrawApproval[msg.sender] = false;
        balances[msg.sender] -= value;
        (bool success,) = payable(msg.sender).call{value: value}("");
        require(success, "Error_TransferFail");

        emit Withdrawal(msg.sender, value);
    }

    function approve(address studentAddress) public onlyOwner {
        withdrawApproval[studentAddress] = true;

        emit Approve(studentAddress, true);
    }

    // TODO: Implementasi transfer function
    function transfer(address to, uint256 value) public {
        require(to != address(0), "Error_TransferIsZero");
        require(to != msg.sender, "Error_ToIsSender");
        require(value > 0, "Error_ValueIsZero");
        require(balances[msg.sender] >= value, "Error_BalanceNotEnough");

        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
    }

    // TODO: Tambah access control
    modifier onlyOwner {
        require(msg.sender == admin, "Error_NotAdmin");

        _;
    }
}