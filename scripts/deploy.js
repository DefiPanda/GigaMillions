// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.

const { ethers } = require("hardhat");
const path = require("path");

async function main() {
  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  const deployerAddress = await deployer.getAddress();
  console.log(
    "Deploying the contracts with the account:",
    deployerAddress
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const MillionJackpot = await ethers.getContractFactory("MillionJackpot");
  const millionJackpot = await Bet.deploy(deployerAddress);
  await millionJackpot.deployed();
  console.log("MillionJackpot contract address:", millionJackpot.address);

  const VRFv2DirectFundingConsumer = await ethers.getContractFactory("VRFv2DirectFundingConsumer");
  const vRFv2DirectFundingConsumer = await Bet.deploy(deployerAddress, millionJackpot.address);
  await vRFv2DirectFundingConsumer.deployed();
  console.log("VRFv2DirectFundingConsumer contract address:", millionJackpot.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });