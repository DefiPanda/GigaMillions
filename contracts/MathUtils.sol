// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

abstract contract MathUtils {

    // 70 * 70 * 70 * 70 * 70 * 25
    uint256 MAX_COMBINATIONS = 42017500000;

    function convertIntToWinningNumbers(uint256 number) internal view returns (uint256[] memory) {
        uint256[] memory winningNumbers;
        uint256 randomNumber = number % MAX_COMBINATIONS;
        winningNumbers[5] = randomNumber % 25;
        randomNumber /= 25;

        for (uint i = 0; i <= 4; i++) {
            winningNumbers[i] = randomNumber % 70;
            randomNumber /= 70;
        }

        return winningNumbers;
    }

}
