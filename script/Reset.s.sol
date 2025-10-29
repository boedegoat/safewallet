// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {FreeNFT} from "../src/FreeNFT.sol";
import {USDT} from "../src/USDT.sol";

contract Reset is Script {
    address victim = vm.envAddress("VICTIM_ADDR");
    address freeNFTAddr = vm.envAddress("FREENFT_ADDR");
    address usdtAddr = vm.envAddress("USDT_ADDR");

    FreeNFT freeNFT;
    USDT usdt;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        usdt = USDT(usdtAddr);
        freeNFT = FreeNFT(freeNFTAddr);
        usdt.mint(victim, 1000e6); // 1000 usdt
        freeNFT.setAttack(false);
        vm.stopBroadcast();
    }
}
