// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {CampusCredit} from "../src/CampusCredit.sol";

contract CounterScript is Script {

    function setUp() public {}

    function run() public {
        // uncomment line below if you want to deploy to anvil (local chain)
        // vm.createSelectFork("anvil");
        vm.startBroadcast();
        new CampusCredit();
        vm.stopBroadcast();

        // you can deploy multichain on a single script by copying lines above and change the chain
    }
}