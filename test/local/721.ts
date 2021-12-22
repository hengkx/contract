// import { ethers, waffle } from 'hardhat';
// import { Contract, Signer, utils } from 'ethers';
// import { expect } from 'chai';

// const provider = waffle.provider;

// const feeRecipients = [
//   ['0x43d6914F10151A3dB15D7aB32bf4c5cD44c48210', 50],
//   ['0x03c2635bDB921baA8af02A2fF97015109966B24b', 50],
// ] as const;

// const saleRecipients = [
//   ['0x03c2635bDB921baA8af02A2fF97015109966B24b', 30],
//   ['0xA63543a9ca882CA4584AF26f10E4161D67517358', 70],
// ] as const;

// const url =
//   'https://4chdy7nzhyneeemy5zgnudwqzkp37zt4rfxwpc7ybv5ie5qsme7a.arweave.net/4I48fbk-GkIRmO5M2g7Qyp-_5nyJb2eL-A16gnYSYT4';

// const feePoints = 20;

// describe('ERC721Tradable', function () {
//   let accounts: Signer[];
//   let market: Contract;
//   let nft: Contract;

//   beforeEach(async function () {
//     accounts = await ethers.getSigners();
//     const Market = await ethers.getContractFactory('Market');
//     market = await Market.deploy();
//     const NFT = await ethers.getContractFactory('ERC721Tradable');
//     nft = await NFT.deploy(
//       market.address,
//       saleRecipients,
//       feePoints,
//       feeRecipients,
//       '',
//     );
//   });

//   it('only owner pause or unpause', async function () {
//     await nft.connect(accounts[0]).pause();
//     expect(await nft.paused()).to.true;
//     await nft.connect(accounts[0]).unpause();
//     expect(await nft.paused()).to.false;
//     await expect(nft.connect(accounts[1]).pause()).to.reverted;
//     expect(await nft.paused()).to.false;
//   });

//   it('721', async function () {
//     const account = await accounts[0].getAddress();
//     let res = await (await nft.mint(1, account, url)).wait();
//     const tokenId = res.events[0].args.tokenId;
//     let price = utils.parseEther('1');
//     res = await market
//       .connect(accounts[0])
//       .createSellOrder(nft.address, tokenId, price, 1, 721);
//     res = await res.wait();
//     let orderId = res.events[0].args.orderId;
//     console.log('初次销售设置价格完成');
//     res = await market.connect(accounts[1]).buy(orderId, 1, { value: price });
//     await res.wait();
//     console.log('初次购买完成');
//     price = utils.parseEther('2');
//     res = await market
//       .connect(accounts[1])
//       .createSellOrder(nft.address, tokenId, price, 1, 721);
//     res = await res.wait();
//     orderId = res.events[0].args.orderId;
//     console.log('二次销售设置价格完成');

//     res = await market.connect(accounts[0]).buy(orderId, 1, { value: price });
//     await res.wait();
//     console.log('二次购买完成');

//     price = utils.parseEther('1');
//     res = await market
//       .connect(accounts[0])
//       .createSellOrder(nft.address, tokenId, price, 1, 721);
//     res = await res.wait();
//     orderId = res.events[0].args.orderId;
//     console.log('三次销售设置价格');

//     res = await market.connect(accounts[1]).buy(orderId, 1, { value: price });
//     await res.wait();
//     console.log('三次购买完成');
//   });
// });
