const { ethers } = require("hardhat");

const WALLET_KEY = "";

async function main() {
    const provider = new ethers.providers.JsonRpcProvider("https://goerli-rollup.arbitrum.io/rpc", 421613);
    const signer = new ethers.Wallet(WALLET_KEY, provider);

    const millionJackpot = await ethers.getContractAt("MillionJackpot", "0x5626492fb1cF10fc96dC313ed7099E9F59A5648c", signer);

    const winningLottery = await millionJackpot.randomizerCallback(1, ethers.utils.hexZeroPad(ethers.utils.hexlify(420131750002123), 32));
    console.log(winningLottery);   

    const transactionReceipt = await winningLottery.wait(1);
    console.log(transactionReceipt);
    console.log(transactionReceipt.gasUsed);
}

if (require.main === module) {
    main()
      .then(() => process.exit(0))
      .catch((error) => {
        console.error(error);
        process.exit(1);
      });
  }