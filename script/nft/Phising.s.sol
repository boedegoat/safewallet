// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Simulation} from "../Simulation.s.sol";
import {PostCheckedDelegationContract} from "../../src/wallet/PostCheckedDelegationContract.sol";
import {FreeNFT} from "../../src/token/FreeNFT.sol";
import {USDT} from "../../src/token/USDT.sol";
import {NFT_SCAM} from "../../src/nft-scam/NFT_SCAM_2.sol";

contract NFTPhising is Script {
    uint256 deployerPk;
    uint256 victimPk;
    bool isSpoof;
    bool isPostChecked;

    address victim;
    address safeWallet;
    FreeNFT nft;
    USDT usdt;
    NFT_SCAM nftScam;

    function run() public {
        // === 0. Load env + derived addresses ===
        deployerPk = vm.envUint("DEPLOYER_PK");
        victimPk = vm.envUint("VICTIM_PK");
        isSpoof = vm.envBool("SPOOF");
        isPostChecked = vm.envBool("POST_CHECKED");

        victim = vm.addr(victimPk);

        // === 1. Deploy wallet, tokens, scam using DEPLOYER ===
        vm.startBroadcast(deployerPk);

        // Safe wallet that can post-check bundles
        safeWallet = address(new PostCheckedDelegationContract());

        // Legit-looking NFT + USDT setup
        usdt = new USDT();
        nft = new FreeNFT(address(usdt));

        // Scam contract pretending to buy NFTs
        nftScam = new NFT_SCAM(vm.addr(deployerPk), address(usdt));

        // Fund victim and scam contract with USDT
        usdt.mint(victim, 1_000e6);
        usdt.mint(address(nftScam), 1_000e6);

        vm.stopBroadcast();

        // === 2. Victim gets USDT approval + mints 3 NFTs ===
        vm.startBroadcast(victimPk);

        usdt.approve(address(nft), type(uint256).max);
        for (uint256 i = 0; i < 3; i++) {
            nft.claim();
        }

        vm.stopBroadcast();

        // === 3. Build bundle & simulate honest case ===
        PostCheckedDelegationContract.Transaction[] memory txs = _createTxs();
        PostCheckedDelegationContract.State[] memory states = _simulate(txs);

        // === 4. Spoof mode: arm the scam contract BEFORE victim executes ===
        if (isSpoof) {
            vm.startBroadcast(deployerPk);
            nftScam.attack();
            vm.stopBroadcast();
        }

        // === 5. Victim executes the bundle (direct or post-checked) ===
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

        // 1) Victim gives full approval for all NFTs to the scam contract
        txs[0] = PostCheckedDelegationContract.Transaction({
            target: address(nft),
            data: abi.encodeWithSelector(
                IERC721.setApprovalForAll.selector,
                address(nftScam),
                true
            ),
            value: 0
        });

        // 2) Victim "sells" one NFT (tokenId 0) to the scam contract
        txs[1] = PostCheckedDelegationContract.Transaction({
            target: address(nftScam),
            data: abi.encodeWithSelector(
                NFT_SCAM.trade.selector,
                address(nft),
                0
            ),
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
