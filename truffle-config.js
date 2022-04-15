const HDWalletProvider = require('@truffle/hdwallet-provider')
require('dotenv').config()

module.exports = {
  contracts_build_directory: './build',
  networks: {
    thetaTestnet: {
      provider: () => new HDWalletProvider(process.env.PRIVATE_KEY, 'https://eth-rpc-api-testnet.thetatoken.org/rpc'),
      network_id: 365
    },
    thetaMainnet: {
      provider: () => new HDWalletProvider(process.env.PRIVATE_KEY, 'https://eth-rpc-api.thetatoken.org/rpc'),
      network_id: 361
    },
    maticTestnet: {
      provider: () => new HDWalletProvider(process.env.PRIVATE_KEY, 'https://matic-mumbai.chainstacklabs.com'),
      network_id: 80001
    }
  },
  compilers: {
    solc: {
      version: '0.6.6',
      settings: {
        optimizer: {
          enabled: true,
          // This will generate gas efficient code for as many executions.
          runs: 999999
        }
      }
    }
  },
  plugins: ['truffle-plugin-verify'],
  api_keys: {
    polygonscan: process.env.POLYGONSCAN_KEY
  }
}
