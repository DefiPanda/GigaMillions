// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { IRandomizer } from "../interfaces/IRandomizer.sol";

/*
 *  MillionJackpot is a lottery game, where players guess 6 numbers. Winners that correctly guess all 6 numbers
 *  will split all money in the pool. Winners that correctly guess some numbers will get payout according to
 *  certain rules.
 *
 *  The winning number will be determined approximately every 7 days (subject to change), if there is at least
 *  10,000 USDC in the pool.
 *
 *  Once the winning number is determined, payout will paid in two phase:
 *  Phase 1) First 2 days:
 *     Non-jackpot winners can immediately withdraw the winning.
 *     Jackpot winners can confirm their winning. If the winner doesn't confirm in this phase, the winning
 *     becomes invalid.
 *  Phase 2) After Phase 1 ends:
 *     Admin will send jackpot winners the winnings.
 *     Jackpot winning per each winner = (Total USDC left after Phase 1 payout) / (Total number of winners)
 *
 *  All USDC left in the pool in the last game will roll over to the new game.
 *  
 *  Number 1-5 can be 1-70, number 6 can be 1-25.
 */
contract MillionJackpot is Ownable {
    // Arbitrum Goerli
    address USDC_ADDRESS = 0xc944B73fBA33a773A4A07340333A3184A70aF1ae;
    // Arbitrum Goerli
    IRandomizer public randomizer = IRandomizer(0x923096Da90a3b60eb7E12723fA2E1547BA9236Bc);

    // 70 * 70 * 70 * 70 * 70 * 25
    uint256 MAX_COMBINATIONS = 42017500000;

    address admin;

    uint256 fivePlusZeroPayout;
    uint256 fourPlusOnePayout;
    uint256 fourPlusZeroPayout;
    uint256 threePlusOnePayout;
    uint256 threePlusZeroPayout;
    uint256 twoPlusOnePayout;
    uint256 onePlusOnePayout;
    uint256 zeroPlusOnePayout;
    // This variable track USDCs unclaimed in the last game. This will differentiate the USDCs available
    // in the current game and last. So a new game can be on-going even when the claiming of the old game
    // is still going on.
    // Winner of the last jackpot can only split the pool with USDCs amount equals to lastGamePoolBalance.
    uint256 lastGamePoolBalance;
    // 0 - not started, 1 - phase one.
    uint256 claimPhase;
    uint256 minUSDCDrawBalance;
    uint256[6] winningNumbers;
    address[] jackpotWinners;

    event Flip(uint256 indexed id);
    event FlipResult(uint256 indexed id, uint256 number);

    constructor(address payable _admin) {
        admin = _admin;
        fivePlusZeroPayout = 1000000_000000;
        fourPlusOnePayout = 50000_000000;
        fourPlusZeroPayout = 750_000000;
        threePlusOnePayout = 750_000000;
        threePlusZeroPayout = 35_000000;
        twoPlusOnePayout = 50_000000;
        onePlusOnePayout = 15_000000;
        zeroPlusOnePayout = 10_000000;
        minUSDCDrawBalance = 10000_000000;
        claimPhase = 0;
        winningNumbers = [0, 0, 0, 0, 0, 0];
    }

    // function placeBet() external payable {
    //     //
    // }

    // function claim() external {
    //     //
    // }

    function updateAdmin(address payable _admin) onlyOwner external {
        admin = _admin;
    }

    function updateMinUSDCDrawBalance(uint256 minBalance) onlyOwner external {
        minUSDCDrawBalance = minBalance;
    }

    function updateClaimPhase(uint256 phase) onlyOwner external {
        claimPhase = phase;
    }

    function getClaimPhase() external view returns (uint256) {
        return claimPhase;
    }

    function endPhaseOneAndDistributeJackpot() onlyOwner external {
        uint256 winningAmount = lastGamePoolBalance / jackpotWinners.length;
        for (uint i = 0; i < jackpotWinners.length; i++) {
            IERC20(USDC_ADDRESS).transfer(jackpotWinners[i], winningAmount);
        }
        claimPhase = 0;
    } 

    function decideWinners() onlyOwner external {    
        // rolling out winning number.
        uint256 id = IRandomizer(randomizer).request(1000000);
        emit Flip(id);
    }

    function convertIntToWinningNumbers(uint256 number) external view returns (uint256[6] memory) {
        uint256[6] memory lotteryResults;
        uint256 randomNumber = number % MAX_COMBINATIONS;
        lotteryResults[5] = (randomNumber % 25) + 1;
        randomNumber /= 25;

        for (uint i = 0; i <= 4; i++) {
            lotteryResults[i] = (randomNumber % 70) + 1;
            randomNumber /= 70;
        }

        return lotteryResults;
    }

    function getUSDCBalance() external view returns (uint256) {
        return IERC20(USDC_ADDRESS).balanceOf(address(this));
    }

    function randomizerCallback(uint256 _id, bytes32 _value) external {
        require(address(randomizer) == msg.sender, "not-randomizer");
        uint256 usdcBalance = IERC20(USDC_ADDRESS).balanceOf(address(this));
        require(usdcBalance >= minUSDCDrawBalance, "Don't have enough USDC blanace");
        require(claimPhase == 0, "Another claim is going on");

        emit FlipResult(_id, uint256(_value));

        uint256[6] memory lotteryResults = this.convertIntToWinningNumbers(uint256(_value));
        for (uint i = 0; i < lotteryResults.length; i++) {
            winningNumbers[i] = lotteryResults[i];
        }
       
        uint256 adminFees = lastGamePoolBalance / 5;
        IERC20(USDC_ADDRESS).transfer(admin, adminFees);

        lastGamePoolBalance = IERC20(USDC_ADDRESS).balanceOf(address(this));
        claimPhase = 1;
    }

    function getWinningNumbers() external view returns (uint256[6] memory) {
        uint256[6] memory winningNumberCalldata;
        for (uint i = 0; i < winningNumbers.length; i++) {
            winningNumberCalldata[i] = winningNumbers[i];
        }
        return winningNumberCalldata;
    }

    function randomizerWithdraw(address _randomizer, uint256 amount) onlyOwner external {
        IRandomizer(_randomizer).clientWithdrawTo(msg.sender, amount);
    }
}