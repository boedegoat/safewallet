// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Simulation} from "../Simulation.s.sol";
import {PostCheckedDelegationContract} from "../../src/wallet/PostCheckedDelegationContract.sol";
import {Drainer} from "../../src/eth/Drainer.sol";

contract ETHPhising is Script {
    uint256 deployerPk = vm.envUint("DEPLOYER_PK");
    uint256 victimPk = vm.envUint("VICTIM_PK");
    bool isSpoof = vm.envBool("SPOOF");
    bool isPostChecked = vm.envBool("POST_CHECKED");
    address victim = vm.addr(victimPk);
    Drainer drainer;
    address safeWallet;

    function run() public {
        // SETUP
        vm.startBroadcast(deployerPk);
        // DEPLOY SAFE WALLET FOR VICTIM
        safeWallet = address(new PostCheckedDelegationContract());

        // DEPLOY PHISING CONTRACTS
        drainer = new Drainer{value: 0.01 ether}();
        vm.stopBroadcast();

        // CREATE TRANSACTIONS
        PostCheckedDelegationContract.Transaction[] memory txs = _createTxs();

        // RUN SIMULATION TO GET ASSET CHANGES
        PostCheckedDelegationContract.State[] memory states = _simulate(txs);

        // SPOOF TRANSACTION
        if (isSpoof) {
            vm.startBroadcast(deployerPk);
            drainer.add(victim);
            vm.stopBroadcast();
        }

        // PERFORM TRANSACT AS VICTIM
        vm.startBroadcast(victimPk);

        if (isPostChecked) {
            vm.signAndAttachDelegation(safeWallet, victimPk);
            (bool success, ) = victim.call{value: txs[0].value}(
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
            memory txs = new PostCheckedDelegationContract.Transaction[](1);
        txs[0] = PostCheckedDelegationContract.Transaction({
            target: address(drainer),
            data: abi.encodeWithSelector(Drainer.claim.selector),
            value: 0.001 ether
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
