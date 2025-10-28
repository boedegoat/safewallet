// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FreeNFT} from "../src/FreeNFT.sol";
import {USDT} from "../src/USDT.sol";

contract TestContract is Test {
    FreeNFT freeNFT;
    USDT usdt;
    address victim = makeAddr("victim");

    function setUp() public {
        usdt = new USDT();
        freeNFT = new FreeNFT(address(usdt));
        usdt.mint(victim, 1000e6); // 1000 usdt
    }

    function testClaim() public {
        vm.startPrank(victim, victim);

        console.log("victim usdt balance:", usdt.balanceOf(victim));

        usdt.approve(address(freeNFT), type(uint256).max);
        freeNFT.claim();
        console.log("claim called");

        console.log("victim usdt balance:", usdt.balanceOf(victim));
        console.log("victim nft balance:", freeNFT.balanceOf(victim));

        vm.stopPrank();
    }
}
