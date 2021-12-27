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
    const address = await accounts[0].getAddress();
    const order = [
      '0x9454c9090074e7377ed6f8645708Dd529B3b0C15',
      1,
      721,
      address,
      utils.parseEther('1'),
      1,
      1640224858,
      1640224858,
      1640224858,
    ];
    const abi = new utils.AbiCoder();
    const hash = utils.keccak256(
      abi.encode(
        [
          'address',
          'uint256',
          'uint256',
          'address',
          'uint256',
          'uint256',
          'uint256',
          'uint256',
          'uint256',
        ],
        order,
      ),
    );
    const sig = await accounts[0].signMessage(hash);
    const sigLike = utils.splitSignature(sig);
    const s = [sigLike.v, sigLike.r, sigLike.s];
    expect(await market.validateOrder(order, s)).to.be.true;
  });
});
