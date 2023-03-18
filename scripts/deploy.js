// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.

const { ethers } = require("hardhat");
const path = require("path");

async function main() {
  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  const deployerAddress = await deployer.getAddress();
  console.log(
    "Deploying the contracts with the account address:",
    deployerAddress
  );

  const MillionJackpot = await ethers.getContractFactory("MillionJackpot");
  const millionJackpot = await MillionJackpot.deploy(deployerAddress);
  const deployedMillionJackpot = await millionJackpot.deployed();
  console.log("MillionJackpot contract address:", deployedMillionJackpot.address);
}

if (require.main === module) {
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}