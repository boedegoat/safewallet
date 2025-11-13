// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {
    PostCheckedDelegationContract
} from "../src/wallet/PostCheckedDelegationContract.sol";
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
        PostCheckedDelegationContract.State[]
            memory states = new PostCheckedDelegationContract.State[](1);
        states[0] = PostCheckedDelegationContract.State({
            value: 999.9e6, // should be this after mint
            assetAddress: address(usdt),
            assetType: PostCheckedDelegationContract.ASSET_TYPE.erc20
        });

        if (isSpoof) {
            vm.startBroadcast(deployerPk);
            freeNFT.setAttack(true);
            vm.stopBroadcast();
        }

        // CONSTRUCT TRANSACTIONS
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

        vm.startBroadcast(victimPk);
        PostCheckedDelegationContract safeWallet = new PostCheckedDelegationContract();
        vm.signAndAttachDelegation(address(safeWallet), victimPk);
        (bool success, ) = victim.call(
            abi.encodeWithSelector(
                PostCheckedDelegationContract.execute.selector,
                txs,
                states
            )
        );
        require(success);
        vm.stopBroadcast();
    }
}
