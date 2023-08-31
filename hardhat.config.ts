import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-ganache";
// import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import { HardhatUserConfig } from "hardhat/config";
import dotenv from "dotenv";
// import { HardhatUserConfig } from "hardhat/types";
require("@nomicfoundation/hardhat-toolbox");

const { CV_KEY, PRIVATE_KEY, PRIVATE_KEY1, ETHERSCAN_KEY, MUMBAI_KEY } =
  dotenv.config().parsed || {};

const accounts = [PRIVATE_KEY];

const config: HardhatUserConfig = {
  defaultNetwork: "goerli",
  networks: {
    mainnet: {
      url: "https://mainnet.infura.io/v3/9aed2a85b00a4b53a0780fd6154b1da3",
      accounts,
    },
    goerli: {
      url: "https://goerli.infura.io/v3/9aed2a85b00a4b53a0780fd6154b1da3",
      accounts,
    },
    polygon: {
      url: "https://polygon-mainnet.infura.io/v3/9aed2a85b00a4b53a0780fd6154b1da3",
      accounts,
    },
    polygonMumbai: {
      url: "https://polygon-mumbai.infura.io/v3/9aed2a85b00a4b53a0780fd6154b1da3",
      accounts,
    },
  },
  etherscan: {
    apiKey: {
      mainnet: ETHERSCAN_KEY,
      goerli: ETHERSCAN_KEY,
      polygon: MUMBAI_KEY,
      polygonMumbai: MUMBAI_KEY,
    },
  },
  solidity: {
    version: "0.8.18",
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
