// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/token.sol";

contract TokenScript is Script {
    function run() external {
        vm.startBroadcast();

        SDUFECoin token = new SDUFECoin("SDUFECoinTest", "SDCT", 8);

        vm.stopBroadcast();
    }
}