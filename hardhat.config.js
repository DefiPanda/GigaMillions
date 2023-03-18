require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-waffle");

const { ARBITRUM_PRIVATE_KEY } = process.env;

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
  etherscan: {
    apiKey: {
      arbitrumOne: "MEUN92TNV34TAPPNVYHYPGU2BD9Z6JJCI5",
      arbitrumGoerli: "MEUN92TNV34TAPPNVYHYPGU2BD9Z6JJCI5",
    }
  },
  networks: {
    arbitrum: {
        url: `https://arb1.arbitrum.io/rpc`,
        chainId: 42161,
        accounts: [ARBITRUM_PRIVATE_KEY],
    },
    arbitrum_goerli: {
        url: `https://goerli-rollup.arbitrum.io/rpc`,
        chainId: 421613,
        accounts: [ARBITRUM_PRIVATE_KEY]
    }
  }
};