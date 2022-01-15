import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-ganache';
import '@nomiclabs/hardhat-waffle';
import { HardhatUserConfig } from 'hardhat/config';
import dotenv from 'dotenv';

const { PRIVATE_KEY, PRIVATE_KEY1, ETHERSCAN_KEY, MUMBAI_KEY } = dotenv.config().parsed || {};

const config: HardhatUserConfig = {
  defaultNetwork: 'rinkeby',
  networks: {
    rinkeby: {
      url: 'https://rinkeby.infura.io/v3/868df5ff3ca64bdc8ae50772874a6682',
      // url: 'https://eth-rinkeby.alchemyapi.io/v2/IZcjQxK29GvxCuSHPc2afnlCho-_a4n8',
      accounts: [PRIVATE_KEY, PRIVATE_KEY1],
    },
    mumbai: {
      url: 'https://polygon-mumbai.infura.io/v3/9aed2a85b00a4b53a0780fd6154b1da3',
      accounts: [PRIVATE_KEY, PRIVATE_KEY1],
    },
  },
  etherscan: {
    // apiKey: ETHERSCAN_KEY,
    apiKey: MUMBAI_KEY,
  },
  solidity: {
    version: '0.8.9',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  mocha: {
    timeout: 2000000,
  },
};

export default config;
