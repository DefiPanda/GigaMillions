// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import { IRandomizer } from "../interfaces/IRandomizer.sol";
import { MathUtils } from "./MathUtils.sol";

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
contract MillionJackpot is Ownable, MathUtils {
    // Arbitrum Goerli
    address USDC_ADDRESS = 0xD87Ba7A50B2E7E660f678A895E4B72E7CB4CCd9C;
    // Arbitrum Goerli
    IRandomizer public randomizer = IRandomizer(0x923096Da90a3b60eb7E12723fA2E1547BA9236Bc);

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
    uint256 minUSDCDrawBalance;
    uint256 blockPerDay;
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

    function updateMinUSDCDrawBalance(uint256 minBalance) onlyOwner external {
        minUSDCDrawBalance = minBalance;
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
        uint256 id = IRandomizer(randomizer).request(50000);
        emit Flip(id);
    }

    function randomizerCallback(uint256 _id, bytes32 _value) external {
        require(address(randomizer) == msg.sender, "not-randomizer");
        uint usdcBalance = IERC20(USDC_ADDRESS).balanceOf(address(this));
        require(usdcBalance >= minUSDCDrawBalance, "Don't have enough USDC blanace");
        require(block.number > newDrawEligibileBlockNumber, "Can't start draw yet");
        require(block.number > winningPhaseTwoEndBlockNumber, "Still claming last game");

        emit FlipResult(_id, uint256(_value));

        uint256[] memory lotteryResults = MathUtils.convertIntToWinningNumbers(uint256(_value));
        for (uint i = 0; i < lotteryResults.length; i++) {
            winningNumbers[i] = lotteryResults[i];
        }
       
        lastGamePoolBalance = usdcBalance;
        newDrawEligibileBlockNumber = block.number + blockPerDay * newDrawEligibileDays;
        winningPhaseOneEndBlockNumber = block.number + blockPerDay * winningPhaseOneDays;
        winningPhaseTwoEndBlockNumber = block.number + blockPerDay * winningPhaseTwoDays;
    }

    function getNewDrawEligibileBlockNumber() external view returns (uint256) {
        return newDrawEligibileBlockNumber;
    }

    function getWinningPhaseOneEndBlockNumber() external view returns (uint256) {
        return winningPhaseOneEndBlockNumber;
    }

    function getWinningPhaseTwoEndBlockNumber() external view returns (uint256) {
        return winningPhaseTwoEndBlockNumber;
    }

    function getWinningNumbers() external view returns (uint256[] memory) {
        uint256[] memory winningNumberCalldata;
        for (uint i = 0; i < winningNumbers.length; i++) {
            winningNumberCalldata[i] = winningNumbers[i];
        }
        return winningNumberCalldata;
    }

    function randomizerWithdraw(address _randomizer, uint256 amount) onlyOwner external {
        IRandomizer(_randomizer).clientWithdrawTo(msg.sender, amount);
    }
}