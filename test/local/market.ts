import { ethers, network, waffle } from 'hardhat';
import { Contract, Signer, utils } from 'ethers';
import { expect } from 'chai';

const provider = waffle.provider;
const abi = new utils.AbiCoder();

const ORDER_TYPE_HASH = utils.keccak256(
  utils.toUtf8Bytes(
    'Order(address tokenAddress,uint256 tokenId,uint256 tokenType,address maker,uint256 price,uint256 amount,uint256 listingTime,uint256 expirationTime,uint256 salt)',
  ),
);
console.log(ORDER_TYPE_HASH);
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

    const domain = {
      name: 'Tom Xu',
      version: '1.0.0',
      chainId: network.config.chainId,
      verifyingContract: market.address,
    };

    const order = {
      tokenAddress: '0x9454c9090074e7377ed6f8645708Dd529B3b0C15',
      tokenId: 1,
      tokenType: 721,
      maker: address,
      price: utils.parseEther('1'),
      amount: 1,
      listingTime: 1640224858,
      expirationTime: 1640224858,
      salt: 1640224858,
    };
    const types = {
      Order: [
        { name: 'tokenAddress', type: 'address' },
        { name: 'tokenId', type: 'uint256' },
        { name: 'tokenType', type: 'uint256' },
        { name: 'maker', type: 'address' },
        { name: 'price', type: 'uint256' },
        { name: 'amount', type: 'uint256' },
        { name: 'listingTime', type: 'uint256' },
        { name: 'expirationTime', type: 'uint256' },
        { name: 'salt', type: 'uint256' },
      ],
    };

    const hash = utils._TypedDataEncoder.hash(domain, types, order);
    const sig = await accounts[0].signMessage(hash);
    expect(
      await market.validateOrder(
        Object.entries(order).map((item) => item[1]),
        sig,
      ),
    ).to.be.true;
  });
});
