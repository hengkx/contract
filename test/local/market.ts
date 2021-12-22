import { ethers, waffle } from 'hardhat';
import { Contract, Signer, utils } from 'ethers';
import { expect } from 'chai';

const provider = waffle.provider;

describe('Market', function () {
  let accounts: Signer[];
  let market: Contract;

  beforeEach(async function () {
    accounts = await ethers.getSigners();
    const Market = await ethers.getContractFactory('MarketV2');
    market = await Market.deploy();
  });

  it('test', async function () {
    const order = [
      '0x9454c9090074e7377ed6f8645708Dd529B3b0C15',
      1,
      721,
      '0x9454c9090074e7377ed6f8645708Dd529B3b0C15',
      utils.parseEther('1'),
      1,
      Date.now(),
      Date.now(),
      Math.round(Math.random() * 10000000000),
    ];
    // const abi = new utils.AbiCoder();
    // const hash = utils.keccak256(
    //   abi.encode(
    //     [
    //       'string',
    //       'uint256',
    //       'uint256',
    //       'string',
    //       'uint256',
    //       'uint256',
    //       'uint256',
    //       'uint256',
    //       'uint256',
    //     ],
    //     order,
    //   ),
    // );
    // console.log(accounts[0].signMessage(hash));
    // console.log(await market.validateOrder(order, ''));
    // accounts[0].signMessage()
  });
});
