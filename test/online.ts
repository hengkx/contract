import { artifacts, ethers, waffle } from 'hardhat';
import { Contract, Signer, utils } from 'ethers';
import { expect } from 'chai';

const provider = waffle.provider;

const feeRecipients = [
  ['0x43d6914F10151A3dB15D7aB32bf4c5cD44c48210', 50],
  ['0x03c2635bDB921baA8af02A2fF97015109966B24b', 50],
] as const;

const saleRecipients = [
  ['0x03c2635bDB921baA8af02A2fF97015109966B24b', 30],
  ['0xA63543a9ca882CA4584AF26f10E4161D67517358', 70],
] as const;

const url =
  'https://4chdy7nzhyneeemy5zgnudwqzkp37zt4rfxwpc7ybv5ie5qsme7a.arweave.net/4I48fbk-GkIRmO5M2g7Qyp-_5nyJb2eL-A16gnYSYT4';

const feePoints = 20;

const marketAddress = '0x94D93c28277eeaf7F4f4994D679B4639E1a62B20';
const nftAddress = '0xEbA54D8b4FaD9e898272D8da79Ee3f19657Dc606';
const nft1155Address = '0x69dd4dbe1e3D576e366587B3573Fba76dD3eF33C';

describe('online', function () {
  let accounts: Signer[];
  let market: Contract;
  let nft: Contract;
  let nft1155: Contract;

  beforeEach(async function () {
    accounts = await ethers.getSigners();
    market = new ethers.Contract(
      marketAddress,
      artifacts.readArtifactSync('Market').abi,
    );
    nft = new ethers.Contract(
      nftAddress,
      artifacts.readArtifactSync('ERC721Tradable').abi,
    );

    nft1155 = new ethers.Contract(
      nft1155Address,
      artifacts.readArtifactSync('ERC1155Tradable').abi,
    );
  });

  // it('721', async function () {
  //   let price = utils.parseEther('1');
  //   let tokenId = 1;
  //   let res = await market
  //     .connect(accounts[0])
  //     .createSellOrder(nft.address, tokenId, price, 1, false);
  //   await res.wait();
  //   console.log('初次销售设置价格完成');
  //   res = await market
  //     .connect(accounts[1])
  //     .buy(nft.address, tokenId, { value: price });
  //   await res.wait();
  //   console.log('初次购买完成');
  //   price = utils.parseEther('2');
  //   res = await market
  //     .connect(accounts[1])
  //     .createSellOrder(nft.address, tokenId, price, 1, false);
  //   await res.wait();
  //   console.log('二次销售设置价格完成');

  //   res = await market
  //     .connect(accounts[0])
  //     .buy(nft.address, tokenId, { value: price });
  //   await res.wait();
  //   console.log('二次购买完成');

  //   price = utils.parseEther('1');
  //   res = await market
  //     .connect(accounts[0])
  //     .createSellOrder(nft.address, tokenId, price, 1, false);
  //   await res.wait();
  //   console.log('三次销售设置价格');
  //   res = await market
  //     .connect(accounts[1])
  //     .buy(nft.address, tokenId, { value: price });
  //   await res.wait();
  //   console.log('三次购买完成');
  // });

  it('1155', async function () {
    let price = utils.parseEther('1');
    let tokenId = 1;
    let res = await market
      .connect(accounts[0])
      .createSellOrder(nft1155.address, tokenId, price, 6, true);
    await res.wait();
    console.log('初次销售设置价格完成');
    res = await market
      .connect(accounts[1])
      .buy1155(1, 3, { value: price.mul(3) });
    await res.wait();
    console.log('初次购买完成');
    price = utils.parseEther('2');
    res = await market
      .connect(accounts[1])
      .createSellOrder(nft1155.address, tokenId, price, 3, true);
    await res.wait();
    console.log('二次销售设置价格完成');

    res = await market
      .connect(accounts[0])
      .buy1155(2, 2, { value: price.mul(2) });
    await res.wait();
    console.log('二次购买完成');

    price = utils.parseEther('1');
    res = await market
      .connect(accounts[0])
      .createSellOrder(nft1155.address, tokenId, price, 8, true);
    await res.wait();
    console.log('三次销售设置价格');
    res = await market
      .connect(accounts[1])
      .buy1155(3, 8, { value: price.mul(8) });
    await res.wait();
    console.log('三次购买完成');
  });
});
