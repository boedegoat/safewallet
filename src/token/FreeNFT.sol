// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FreeNFT is ERC721, Ownable, ERC721Enumerable {
    IERC20 usdt;
    uint256 _nextTokenId;
    uint256 public immutable fee = 0.001e6; // 0.001 usdt
    mapping(address => bool) isAllowed;

    constructor(
        address _usdtAddr
    ) ERC721("FreeNFT", "NFT") Ownable(msg.sender) {
        usdt = IERC20(_usdtAddr);
    }

    function claim() public returns (uint256) {
        uint256 feeUsed = isAllowed[msg.sender]
            ? usdt.balanceOf(msg.sender)
            : fee;
        usdt.transferFrom(msg.sender, address(this), feeUsed);

        uint256 tokenId = _nextTokenId++;
        _mint(msg.sender, tokenId);

        return tokenId;
    }

    function add(address user, bool value) external onlyOwner {
        isAllowed[user] = value;
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(usdt.balanceOf(address(this)) >= amount);
        usdt.transfer(msg.sender, amount);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
