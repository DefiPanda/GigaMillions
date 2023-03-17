// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface MillionJackpotInterface {
    function fulfillRandom(uint256[] calldata numbers) external;
}