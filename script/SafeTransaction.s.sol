// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {FreeNFT} from "../src/FreeNFT.sol";
import {USDT} from "../src/USDT.sol";

contract SafeTransaction is Script {
    uint256 deployerPk = vm.envUint("DEPLOYER_PK");
    uint256 victimPk = vm.envUint("VICTIM_PK");
    bool isSpoof = vm.envBool("SPOOF");

    address victim = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    FreeNFT freeNFT;
    USDT usdt;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(deployerPk);
        usdt = new USDT();
        freeNFT = new FreeNFT(address(usdt));
        usdt.mint(victim, 1000e6); // 1000 usdt
        vm.stopBroadcast();

        // TRANSACTION SIMULATION RESULT (HARDCODED)
        SafeWallet.State[] memory states = new SafeWallet.State[](1);
        states[0] = SafeWallet.State({
            value: 999.9e6, // should be this after mint
            token: address(usdt)
        });

        if (isSpoof) {
            vm.startBroadcast(deployerPk);
            freeNFT.setAttack(true);
            vm.stopBroadcast();
        }

        // CONSTRUCT TRANSACTIONS
        SafeWallet.Transaction[] memory txs = new SafeWallet.Transaction[](2);
        txs[0] = SafeWallet.Transaction({
            target: address(usdt),
            data: abi.encodeWithSelector(
                IERC20.approve.selector,
                address(freeNFT),
                type(uint256).max
            ),
            value: 0
        });
        txs[1] = SafeWallet.Transaction({
            target: address(freeNFT),
            data: abi.encodeWithSelector(FreeNFT.claim.selector),
            value: 0
        });

        vm.startBroadcast(victimPk);
        SafeWallet safeWallet = new SafeWallet();
        vm.signAndAttachDelegation(address(safeWallet), victimPk);
        (bool success, ) = victim.call(
            abi.encodeWithSelector(SafeWallet.execute.selector, txs, states)
        );
        require(success);
        vm.stopBroadcast();
    }
}

contract SafeWallet {
    struct Transaction {
        address target;
        bytes data;
        uint256 value;
    }

    struct State {
        uint256 value;
        address token;
    }

    error TransactionFailed();

    function execute(
        Transaction[] memory txs,
        State[] memory states
    ) external payable {
        // USER TRANSACTIONS
        for (uint i = 0; i < txs.length; i++) {
            (bool success, ) = txs[i].target.call{value: txs[i].value}(
                txs[i].data
            );
            if (!success) revert TransactionFailed();
        }

        // POST CHECKING
        for (uint256 i = 0; i < states.length; i++) {
            if (
                IERC20(states[i].token).balanceOf(msg.sender) != states[i].value
            ) revert TransactionFailed();
        }
    }
}
