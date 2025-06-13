// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {WeightedMultiSigWallet} from "../src/WeightedMultiSigWallet.sol";

contract WeightedMultiSigWalletScript is Script {
    WeightedMultiSigWallet public multiSigWallet;

    function run() public {
        vm.startBroadcast();
        multiSigWallet = new WeightedMultiSigWallet(
            10143,
            10000
        );
        vm.stopBroadcast();
    }
}