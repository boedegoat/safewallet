// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract PostCheckedDelegationContract {
    enum ASSET_TYPE {
        eth,
        erc20,
        erc721
    }

    struct Transaction {
        address target;
        bytes data;
        uint256 value;
    }

    struct State {
        uint256 value;
        address assetAddress;
        ASSET_TYPE assetType;
    }

    error TransactionFailed();
    error ETHMissmatch();
    error ERC20Missmatch(address token);
    error ERC721Missmatch(address nft);

    function execute(
        Transaction[] memory txs,
        State[] memory states
    ) external payable {
        // USER TRANSACTIONS
        for (uint256 i = 0; i < txs.length; i++) {
            (bool success, ) = txs[i].target.call{value: txs[i].value}(
                txs[i].data
            );
            if (!success) revert TransactionFailed();
        }

        // POST CHECKING
        for (uint256 i = 0; i < states.length; i++) {
            State memory state = states[i];
            if (
                state.assetType == ASSET_TYPE.eth &&
                msg.sender.balance != state.value
            ) revert ETHMissmatch();
            else if (
                state.assetType == ASSET_TYPE.erc20 &&
                IERC20(state.assetAddress).balanceOf(msg.sender) != state.value
            ) revert ERC20Missmatch(state.assetAddress);
            else if (
                state.assetType == ASSET_TYPE.erc721 &&
                IERC721(state.assetAddress).balanceOf(msg.sender) != state.value
            ) revert ERC721Missmatch(state.assetAddress);
        }
    }
}
