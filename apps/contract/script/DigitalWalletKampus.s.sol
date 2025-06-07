// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {DigitalWalletKampus} from "../src/DigitalWalletKampus.sol";
import {SistemAkademik} from "../src/SistemAkademik.sol";
import {PemilihanBEM} from "../src/PemilihanBem.sol";

contract DigitalWalletKampusScript is Script {
    DigitalWalletKampus public digitalWalletKampus;

    function setUp() public {}

    function run() public {
        // uncomment line below if you want to deploy to anvil (local chain)
        // vm.createSelectFork("anvil");
        vm.startBroadcast();
        digitalWalletKampus = new DigitalWalletKampus();
        new SistemAkademik();
        new PemilihanBEM();
        vm.stopBroadcast();

        // you can deploy multichain on a single script by copying lines above and change the chain
    }
}