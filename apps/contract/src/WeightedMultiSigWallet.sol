// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {WalletGovToken} from "./WalletGovToken.sol";

contract WeightedMultiSigWallet {
    using ECDSA for bytes32;

    event Executor(address executor);
    event ExecuteTransaction(
        address indexed owner,
        address payable to,
        uint256 value,
        bytes data,
        uint256 nonce,
        bytes32 hash,
        bytes result
    );

    uint256 public quorumPerMillion;
    uint256 public nonce;
    uint256 public chainId;

    mapping(address => bool) public executors;
    uint256 public executorCount = 1;

    WalletGovToken public govToken;
    uint256 public constant govTokenSupply = 1000000;

    modifier onlySelf() {
        require(msg.sender == address(this), "Not Self");
        _;
    }

    modifier onlyExecutors() {
        require(executors[msg.sender], "Not an executor");
        _;
    }

    receive() external payable {}

    constructor(uint256 _chainId, uint256 _quorumPerMillion) {
        require(
            _quorumPerMillion > 0,
            "constructor: must be non-zero sigs required"
        );
        quorumPerMillion = _quorumPerMillion;
        chainId = _chainId;
        govToken = new WalletGovToken(govTokenSupply, msg.sender);
        executors[msg.sender] = true;
        emit Executor(msg.sender);
    }

    function recover(
        bytes32 _hash,
        bytes memory _signature
    ) public pure returns (address) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)).recover(_signature);
    }

    function hasWeight() public view returns (bool) {
        return govToken.balanceOf(msg.sender) > 0;
    }

    /*
        Wallet inner settings
    */

    function updateQuorumPerMillion(
        uint256 _newQuorumPerMillion
    ) external onlySelf {
        require(
            _newQuorumPerMillion > 0,
            "updateQuorumPerMillion: must be non-zero sigs required"
        );
        quorumPerMillion = _newQuorumPerMillion;
    }

    function addExecutor(address newExecutor) external onlySelf {
        executors[newExecutor] = true;
        executorCount++;
        emit Executor(newExecutor);
    }

    function removeExecutor(address _oldExecutor) external onlySelf {
        require(executorCount > 1, "Cannot remove the last executor.");
        executors[_oldExecutor] = false;
        executorCount--;
    }
}