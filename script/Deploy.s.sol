// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {FreeNFT} from "../src/FreeNFT.sol";
import {USDT} from "../src/USDT.sol";

contract Deploy is Script {
    address victim = vm.envAddress("VICTIM_ADDR");

    FreeNFT freeNFT;
    USDT usdt;

    function setUp() public {}

    function run() public returns (FreeNFT, USDT) {
        vm.startBroadcast();
        usdt = new USDT();
        freeNFT = new FreeNFT(address(usdt));
        usdt.mint(victim, 1000e6); // 1000 usdt
        vm.stopBroadcast();

        return (freeNFT, usdt);
    }
}
