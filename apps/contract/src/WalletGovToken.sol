// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WalletGovToken is ERC20 {
    address private walletContract;

    constructor(
        uint256 _totalSupply,
        address _mintTo
    ) ERC20("WalletGovToken", "WGT") {
        walletContract = msg.sender;
        super._mint(_mintTo, _totalSupply);
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(
            to != walletContract,
            "Cannot send funds to the wallet contract"
        );
        require(to != address(0), "Cannot send funds to zero address");
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(
            to != walletContract,
            "Cannot send funds to the wallet contract"
        );
        require(to != address(0), "Cannot send funds to zero address");
        return super.transferFrom(from, to, amount);
    }
}