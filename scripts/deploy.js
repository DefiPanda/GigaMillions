// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.

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

  const Bet = await ethers.getContractFactory("Bet");
  const bet = await Bet.deploy(deployerAddress);
  await bet.deployed();

  // 0xE0FEDe509625A0BAf37FbB327C4924C59828a514
  console.log("Bet contract address:", bet.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });