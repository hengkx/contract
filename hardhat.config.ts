import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-ganache';
import '@nomiclabs/hardhat-waffle';
import { HardhatUserConfig } from 'hardhat/config';
import dotenv from 'dotenv';

const { CV_KEY, PRIVATE_KEY, PRIVATE_KEY1, ETHERSCAN_KEY, MUMBAI_KEY } =
  dotenv.config().parsed || {};

const accounts = [CV_KEY, PRIVATE_KEY, PRIVATE_KEY1];

const config: HardhatUserConfig = {
  defaultNetwork: 'rinkeby',
  networks: {
    mainnet: {
      url: 'https://mainnet.infura.io/v3/9aed2a85b00a4b53a0780fd6154b1da3',
      accounts,
    },
    rinkeby: {
      url: 'https://rinkeby.infura.io/v3/9aed2a85b00a4b53a0780fd6154b1da3',
      accounts,
    },
    polygon: {
      url: 'https://polygon-mainnet.infura.io/v3/9aed2a85b00a4b53a0780fd6154b1da3',
      accounts,
    },
    polygonMumbai: {
      url: 'https://polygon-mumbai.infura.io/v3/9aed2a85b00a4b53a0780fd6154b1da3',
      accounts,
    },
  },
  etherscan: {
    apiKey: {
      mainnet: ETHERSCAN_KEY,
      rinkeby: ETHERSCAN_KEY,
      polygon: MUMBAI_KEY,
      polygonMumbai: MUMBAI_KEY,
    },
  },
  solidity: {
    compilers: [
      // {
      //   version: '0.8.9',
      //   settings: {
      //     optimizer: {
      //       enabled: false,
      //       runs: 200,
      //     },
      //   },
      // },
      {
        version: '0.8.15',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
    // overrides: {
    //   'contracts/ProxyRegistry.sol': {
    //     version: '0.8.7',
    //   },
    // },
  },
  mocha: {
    timeout: 2000000,
  },
};

export default config;
