const { ethers } = require("hardhat");

async function main() {
    const provider = new ethers.providers.JsonRpcProvider("https://goerli-rollup.arbitrum.io/rpc", 421613);
    const signer = new ethers.Wallet("", provider);

    const millionJackpot = await ethers.getContractAt("MillionJackpot", "0x197B0141776F7E637c8B648380561376f118D783", signer);
    console.log(await millionJackpot.convertIntToWinningNumbers(2));
}

if (require.main === module) {
    main()
      .then(() => process.exit(0))
      .catch((error) => {
        console.error(error);
        process.exit(1);
      });
  }