// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/Phoenixtto.sol";

contract PhoenixttoScript is Script {
    address constant LAB_ADDR = LAB_DEPLOYED_INSTANCE_ADDR;
    address constant PLAYER = PLAYER_ADDR;
    bytes PUBLIC_KEY = hex"YOUR_PUBLIC_KEY_HERE_WITHOUT_0x";

    Laboratory lab;

    function setUp() public {
        lab = Laboratory(LAB_ADDR);
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        Phoenixtto phoenix = Phoenixtto(lab.addr());
        phoenix.capture(string(PUBLIC_KEY));

        console.log(phoenix.owner());

        vm.stopBroadcast();
    }
}
