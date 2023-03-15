require("@nomicfoundation/hardhat-toolbox");

const { GOERLI_PRIVATE_KEY } = process.env;

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.17"
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
        url: `https://mainnet.infura.io/v3/ebae21367f5742aca395c6656aeb1161`,
        accounts: [GOERLI_PRIVATE_KEY],
    },
    goerli: {
        url: `https://goerli.infura.io/v3/ebae21367f5742aca395c6656aeb1161`,
        accounts: [GOERLI_PRIVATE_KEY]
      }
  }
};