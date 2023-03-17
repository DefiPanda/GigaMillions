// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { MillionJackpotInterface } from "../interfaces/MillionJackpotInterface.sol";
import { VRFInterface } from "../interfaces/VRFInterface.sol";

/*
 *  MillionJackpot is a lottery game, where players guess 6 numbers. Winners that correctly guess all 6 numbers
 *  will split all money in the pool. Winners that correctly guess some numbers will get payout according to
 *  certain rules.
 *
 *  The winning number will be determined approximately every 7 days, if there is at least 10,000 USDC in the pool.
 *
 *  Once the winning number is determined, payout will paid in two phase:
 *  Phase 1) First 2 days:
 *     Non-jackpot winners can immediately withdraw the winning.
 *     Jackpot winners can confirm their winning. If the winner doesn't confirm in this phase, the winning
 *     becomes invalid.
 *  Phase 2) 1 day within Phase 1 ends:
 *     Jackpot winners can withdraw the winning.
 *     Jackpot winning = (Total USDC left after Phase 1 payout) / (Total number of winners)
 *
 *  All USDC left in the pool in the last game will roll over to the new game.
 *  
 *  Number 1-5 can be 1-70, number 6 can be 1-25.
 */
contract MillionJackpot is Ownable {
    // BNB Mainnet:
    // address USDT_ADDRESS = 0x55d398326f99059ff775485246999027b3197955;
    // BNB Testnet:
    address USDT_ADDRESS = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;
    // BNB Mainnet:
    // address VRF_COORDINATOR = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    // BNB Testnet:
    address VRF_COORDINATOR = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;

    address VRFConsumerAddress;
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
    uint256 newDrawEligibileDays;
    uint256 newDrawEligibileBlockNumber;
    uint256 winningPhaseOneDays;
    uint256 winningPhaseOneEndBlockNumber;
    uint256 winningPhaseTwoDays;
    uint256 winningPhaseTwoEndBlockNumber;
    uint256 minUSDTDrawBalance;
    uint256 blockPerDay;
    uint256[6] winningNumbers;
    address[] jackpotWinners;

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
        minUSDTDrawBalance = 10000_000000;
        newDrawEligibileBlockNumber = 0;
        blockPerDay = 28421;
        newDrawEligibileDays = 7;
        winningPhaseOneDays = 2;
        winningPhaseTwoDays = 1;
        winningNumbers = [0, 0, 0, 0, 0, 0];
    }

    function placeBet(uint256 daysForUnlock) external payable {
        //
    }

    function claim() external {
        //
    }

    function claimJackpot() external {
        //
    }

    function updateAdmin(address payable _admin) onlyOwner external {
        admin = _admin;
    }

    function updateMinUSDTDrawBalance(uint256 minBalance) onlyOwner external {
        minUSDTDrawBalance = minBalance;
    }

    function updateBlockPerDay(uint256 blocks) onlyOwner external {
        blockPerDay = blocks;
    }

    function updateNewDrawEligibileDays(uint256 eligibleDays) onlyOwner external {
        newDrawEligibileDays = eligibleDays;
    }

    function updatePhaseOneDays(uint256 phaseOneDays) onlyOwner external {
        winningPhaseOneDays = phaseOneDays;
    }

    function updatePhaseTwoDays(uint256 phaseTwoDays) onlyOwner external {
        winningPhaseTwoDays = phaseTwoDays;
    }

    function updateVRFAddress(address vrfAddress) onlyOwner external {
        VRFConsumerAddress = vrfAddress;
    }

    function decideWinners() onlyOwner external {    
        // rolling out winning number.
        VRFInterface(VRFConsumerAddress).requestRandomWords();
    }

    function fulfillRandom(uint256[] calldata numbers) external {
        require(VRF_COORDINATOR == msg.sender, "not-vrf-coordinator");
        uint usdtBalance = IERC20(USDT_ADDRESS).balanceOf(address(this));
        require(usdtBalance >= minUSDTDrawBalance, "Don't have enough ETH blanace");
        require(block.number > newDrawEligibileBlockNumber, "Can't start draw yet");
        require(block.number > winningPhaseTwoEndBlockNumber, "Still claming last game");

        for (uint i = 0; i < numbers.length; i++) {
            winningNumbers[i] = numbers[i];
        }
       
        lastGamePoolBalance = usdtBalance;
        newDrawEligibileBlockNumber = block.number + blockPerDay * newDrawEligibileDays;
        winningPhaseOneEndBlockNumber = block.number + blockPerDay * winningPhaseOneDays;
        winningPhaseTwoEndBlockNumber = block.number + blockPerDay * winningPhaseTwoDays;
    }

    function getWinningNumbers() external view returns (uint256[] memory) {
        uint256[] memory winningNumberCalldata;
        for (uint i = 0; i < winningNumbers.length; i++) {
            winningNumberCalldata[i] = winningNumbers[i];
        }
        return winningNumberCalldata;
    }
}