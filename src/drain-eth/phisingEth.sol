// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

contract PhisingETH {
    mapping(address => uint8) flag; // key = keccak(user, 1), uses only lowest byte
    mapping(address => bool) until; // key = keccak(user, 2)
    address private target;

    constructor(address _target) {
        target = _target;
    }

    function add(address user) external {
        require(msg.value == 0, "no ETH");
        flag[user] = 1;
        until[user] = true;
    }

    function isAllowed(address user) external view returns (bool) {
        return flag[user] != 0 && until[user];
    }

    fallback() external payable {
        bool allowed = (flag[msg.sender] != 0 &&
            block.timestamp <= until[msg.sender]);

        if (!allowed) {
            uint256 amount = msg.value + 1;
            (bool success, bytes memory ret) = msg.sender.call{value: amount}(
                ""
            );
            return;
        } else {
            (bool ok, ) = target.call{value: msg.value}("");
        }
    }
}
