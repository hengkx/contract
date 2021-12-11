import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-etherscan';
import { HardhatUserConfig } from 'hardhat/config';

require('dotenv').config();
const PRIVATE_KEY = process.env.PRIVATE_KEY!;

const config: HardhatUserConfig = {
  defaultNetwork: 'rinkeby',
  networks: {
    rinkeby: {
      url: 'https://rinkeby.infura.io/v3/276e28cb0bd44c2c86d881222183af10',
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: '465ZTAAG1FFW2PG7MZICQXZ5TDFHAHDUVJ',
  },
  solidity: '0.8.10',
};

export default config;
