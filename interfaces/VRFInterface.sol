// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface VRFInterface {
    function requestRandomWords() external returns (uint256 requestId);
}