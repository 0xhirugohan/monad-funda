// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {CourseBadge} from "../src/CourseBadge.sol";

contract CourseBadgeScript is Script {
    CourseBadge public courseBadge;

    function setUp() public {}

    function run() public {
        // uncomment line below if you want to deploy to anvil (local chain)
        // vm.createSelectFork("anvil");
        vm.startBroadcast();
        courseBadge = new CourseBadge();
        vm.stopBroadcast();

        // you can deploy multichain on a single script by copying lines above and change the chain
    }
}