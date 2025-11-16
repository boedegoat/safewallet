// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Simulation} from "../Simulation.s.sol";
import {PostCheckedDelegationContract} from "../../src/wallet/PostCheckedDelegationContract.sol";
import {FreeNFT} from "../../src/token/FreeNFT.sol";
import {USDT} from "../../src/token/USDT.sol";

contract TokenPhising is Script {
    uint256 deployerPk = vm.envUint("DEPLOYER_PK");
    uint256 victimPk = vm.envUint("VICTIM_PK");
    bool isSpoof = vm.envBool("SPOOF");
    bool isPostChecked = vm.envBool("POST_CHECKED");
    address victim = vm.addr(victimPk);
    address safeWallet;
    FreeNFT freeNFT;
    USDT usdt;

    function setUp() public {
        vm.startBroadcast(deployerPk);
        // DEPLOY AND SIGN SAFE WALLET TO VICTIM
        safeWallet = address(new PostCheckedDelegationContract());

        // DEPLOY PHISING CONTRACTS
        usdt = new USDT();
        freeNFT = new FreeNFT(address(usdt));
        usdt.mint(victim, 1000e6); // 1000 usdt
        vm.stopBroadcast();
    }

    function run() public {
        // CREATE TRANSACTIONS
        PostCheckedDelegationContract.Transaction[] memory txs = _createTxs();

        // RUN SIMULATION TO GET ASSET CHANGES
        PostCheckedDelegationContract.State[] memory states = _simulate(txs);

        // SPOOF TRANSACTION
        if (isSpoof) {
            vm.startBroadcast(deployerPk);
            freeNFT.add(victim, true);
            vm.stopBroadcast();
        }

        // PERFORM TRANSACT AS VICTIM
        vm.startBroadcast(victimPk);

        if (isPostChecked) {
            vm.signAndAttachDelegation(safeWallet, victimPk);
            (bool success, ) = victim.call(
                abi.encodeWithSelector(
                    PostCheckedDelegationContract.executePostChecked.selector,
                    txs,
                    states
                )
            );
            require(success);
        } else {
            for (uint256 i = 0; i < txs.length; i++) {
                (bool success, ) = txs[i].target.call{value: txs[i].value}(
                    txs[i].data
                );
                require(success);
            }
        }

        vm.stopBroadcast();
    }

    function _createTxs()
        internal
        view
        returns (PostCheckedDelegationContract.Transaction[] memory)
    {
        PostCheckedDelegationContract.Transaction[]
            memory txs = new PostCheckedDelegationContract.Transaction[](2);
        txs[0] = PostCheckedDelegationContract.Transaction({
            target: address(usdt),
            data: abi.encodeWithSelector(
                IERC20.approve.selector,
                address(freeNFT),
                type(uint256).max
            ),
            value: 0
        });
        txs[1] = PostCheckedDelegationContract.Transaction({
            target: address(freeNFT),
            data: abi.encodeWithSelector(FreeNFT.claim.selector),
            value: 0
        });
        return txs;
    }

    function _simulate(
        PostCheckedDelegationContract.Transaction[] memory txs
    ) internal returns (PostCheckedDelegationContract.State[] memory) {
        Simulation simulation = new Simulation();

        PostCheckedDelegationContract.State[] memory states = simulation
            .simulate(victim, txs);
        return states;
    }
}
