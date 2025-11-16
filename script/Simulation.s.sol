// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/Vm.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../src/wallet/PostCheckedDelegationContract.sol";

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract Simulation is Script {
    bytes32 private constant ERC20_ERC721_TRANSFER_SIG =
        keccak256("Transfer(address,address,uint256)");
    bytes4 private constant ERC721_INTERFACE_ID = 0x80ac58cd;

    function simulate(
        address from,
        PostCheckedDelegationContract.Transaction[] memory txs
    ) external payable returns (PostCheckedDelegationContract.State[] memory) {
        // Snapshot
        uint256 snap = vm.snapshot();

        // Track initial ETH
        uint256 ethBefore = from.balance;

        // simulate tx
        vm.recordLogs();
        vm.startPrank(from, from);
        for (uint256 i = 0; i < txs.length; i++) {
            (bool success, ) = txs[i].target.call{value: txs[i].value}(
                txs[i].data
            );
            require(success, "tx failed");
        }
        vm.stopPrank();

        Vm.Log[] memory logs = vm.getRecordedLogs();

        // final eth balances
        uint256 ethAfter = from.balance;

        // ETH deltas
        int256 deltaSender = int256(ethAfter) - int256(ethBefore);

        // Count asset events to size the array
        uint256 count = 0;

        // ETH changes
        if (deltaSender != 0) count++;

        // Count ERC20/ERC721 transfers
        for (uint256 i = 0; i < logs.length; i++) {
            if (
                logs[i].topics.length == 3 &&
                logs[i].topics[0] == ERC20_ERC721_TRANSFER_SIG
            ) {
                count++;
            }
        }

        // Allocate final array
        PostCheckedDelegationContract.State[]
            memory result = new PostCheckedDelegationContract.State[](count);
        uint256 idx = 0;

        // Insert ETH changes
        if (deltaSender != 0) {
            result[idx++] = PostCheckedDelegationContract.State({
                value: from.balance,
                assetAddress: address(0),
                assetType: PostCheckedDelegationContract.ASSET_TYPE.eth
            });
        }

        // Insert ERC20 + ERC721 transfers
        for (uint256 i = 0; i < logs.length; i++) {
            Vm.Log memory l = logs[i];

            if (l.topics.length != 3) continue;
            if (l.topics[0] != ERC20_ERC721_TRANSFER_SIG) continue;

            address token = l.emitter;
            bool isERC721 = _isERC721(token);

            uint256 amountOrId = isERC721
                ? IERC721(token).balanceOf(from)
                : IERC20(token).balanceOf(from);

            PostCheckedDelegationContract.ASSET_TYPE t = isERC721
                ? PostCheckedDelegationContract.ASSET_TYPE.erc721
                : PostCheckedDelegationContract.ASSET_TYPE.erc20;

            result[idx++] = PostCheckedDelegationContract.State({
                value: amountOrId,
                assetAddress: token,
                assetType: t
            });
        }

        // revert state to keep fork clean
        vm.revertTo(snap);

        return result;
    }

    // ERC721 detector
    function _isERC721(address token) internal view returns (bool) {
        try IERC165(token).supportsInterface(ERC721_INTERFACE_ID) returns (
            bool ok
        ) {
            return ok;
        } catch {
            return false;
        }
    }
}
