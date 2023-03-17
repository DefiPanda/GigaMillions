require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-waffle");

const { BNB_PRIVATE_KEY } = process.env;

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.7"
      }
    ]
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  networks: {
    mainnet: {
        url: `https://bsc-dataseed1.defibit.io`,
        accounts: [BNB_PRIVATE_KEY],
    },
    goerli: {
        url: `https://endpoints.omniatech.io/v1/bsc/testnet/public`,
        accounts: [BNB_PRIVATE_KEY]
    }
  }
};