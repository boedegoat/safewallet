// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

contract ResetDelegation is Script {
    uint256 victimPk = vm.envUint("VICTIM_PK");
    address eoa = vm.addr(victimPk);

    function run() public {
        vm.startBroadcast(victimPk);

        vm.signAndAttachDelegation(address(0), victimPk);
        (bool ok, ) = eoa.call("");
        require(ok, "clear delegation tx failed");

        vm.stopBroadcast();
    }
}
