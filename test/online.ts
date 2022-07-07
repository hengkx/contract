import { artifacts, ethers } from 'hardhat';
import { Contract, Signer, utils } from 'ethers';

const marketAddress = '0xC81C55d0b04936239983df99880101c41FAB57df';
const nftAddress = '0x396A49921D1002676964Cd7965eb1185354a8d3a';
const nft1155Address = '0xCd5Bf195F037024873cdC410Aa5F010C364FAAa1';

describe('online', function () {
  let accounts: Signer[];
  let market: Contract;
  let nft: Contract;
  let nft1155: Contract;

  beforeEach(async function () {
    accounts = await ethers.getSigners();
    market = new ethers.Contract(marketAddress, artifacts.readArtifactSync('Market').abi);
    nft = new ethers.Contract(nftAddress, artifacts.readArtifactSync('ERC721Tradable').abi);

    nft1155 = new ethers.Contract(
      nft1155Address,
      artifacts.readArtifactSync('ERC1155Tradable').abi,
    );
  });

  it('721', async function () {
    let tokenId = 1;
    let price = utils.parseEther('1');
    let res = await market
      .connect(accounts[0])
      .createSellOrder(nft.address, tokenId, price, 1, 721);
    res = await res.wait();
    let orderId = res.events[0].args.orderId;
    console.log('初次销售设置价格完成');
    res = await market.connect(accounts[1]).buy(orderId, 1, { value: price });
    await res.wait();
    console.log('初次购买完成');
    price = utils.parseEther('2');
    res = await market.connect(accounts[1]).createSellOrder(nft.address, tokenId, price, 1, 721);
    res = await res.wait();
    orderId = res.events[0].args.orderId;
    console.log('二次销售设置价格完成');

    res = await market.connect(accounts[0]).buy(orderId, 1, { value: price });
    await res.wait();
    console.log('二次购买完成');

    price = utils.parseEther('1');
    res = await market.connect(accounts[0]).createSellOrder(nft.address, tokenId, price, 1, 721);
    res = await res.wait();
    orderId = res.events[0].args.orderId;
    console.log('三次销售设置价格');

    res = await market.connect(accounts[1]).buy(orderId, 1, { value: price });
    await res.wait();
    console.log('三次购买完成');
  });

  it('1155', async function () {
    let price = utils.parseEther('1');
    let tokenId = 1;
    let res = await market
      .connect(accounts[0])
      .createSellOrder(nft1155.address, tokenId, price, 6, 1155);
    res = await res.wait();
    let orderId = res.events[0].args.orderId;
    console.log('初次销售设置价格完成');
    res = await market.connect(accounts[1]).buy(orderId, 3, { value: price.mul(3) });
    await res.wait();
    console.log('初次购买完成');
    price = utils.parseEther('2');
    res = await market
      .connect(accounts[1])
      .createSellOrder(nft1155.address, tokenId, price, 3, 1155);
    res = await res.wait();
    orderId = res.events[0].args.orderId;
    console.log('二次销售设置价格完成');

    res = await market.connect(accounts[0]).buy(orderId, 2, { value: price.mul(2) });
    await res.wait();
    console.log('二次购买完成');

    price = utils.parseEther('1');
    res = await market
      .connect(accounts[0])
      .createSellOrder(nft1155.address, tokenId, price, 8, 1155);
    res = await res.wait();
    orderId = res.events[0].args.orderId;
    console.log('三次销售设置价格');
    res = await market.connect(accounts[1]).buy(orderId, 8, { value: price.mul(8) });
    await res.wait();
    console.log('三次购买完成');
  });
});
