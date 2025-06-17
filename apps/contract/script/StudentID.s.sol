// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {StudentID} from "../src/StudentID.sol";

contract StudentIDScript is Script {
    StudentID public studentID;

    function setUp() public {}

    function run() public {
        // uncomment line below if you want to deploy to anvil (local chain)
        // vm.createSelectFork("anvil");
        vm.startBroadcast();
        studentID = new StudentID();
        vm.stopBroadcast();

        // you can deploy multichain on a single script by copying lines above and change the chain
    }
}