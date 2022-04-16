const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

module.exports = {
  contracts_build_directory: './build',
  networks: {
    thetaTestnet: {
      provider: () => new HDWalletProvider(process.env.PRIVATE_KEY, 'https://eth-rpc-api-testnet.thetatoken.org/rpc'),
      network_id: 365,
    },
    rinkeby: {
      provider: () =>
        new HDWalletProvider(process.env.PRIVATE_KEY, 'https://rinkeby.infura.io/v3/fc540662631c4028a8ca161b8c2e0955'),
      network_id: 4,
    },
  },
  compilers: {
    solc: {
      version: '0.8.13',
      settings: {
        optimizer: {
          enabled: true,
          // This will generate gas efficient code for as many executions.
          runs: 999999,
        },
      },
    },
  },
  plugins: ['truffle-plugin-verify'],
  api_keys: {
    etherscan: process.env.ETHERSCAN_KEY,
  },
};
