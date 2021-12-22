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

// describe('Contract', function () {
//   let accounts: Signer[];
//   let market: Contract;
//   let nft: Contract;
//   let nft1155: Contract;

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
//     const NFT1155 = await ethers.getContractFactory('ERC1155Tradable');
//     nft1155 = await NFT1155.deploy(
//       market.address,
//       saleRecipients,
//       20,
//       feeRecipients,
//       '',
//     );
//   });

//   it('721', async function () {
//     const account = await accounts[0].getAddress();

//     const res = await (await nft.mint(account, url)).wait();
//     const tokenId = res.events[0].args.tokenId;
//     let price = utils.parseEther('1');
//     await market.createSellOrder(nft.address, tokenId, price, 1, 721);
//     expect((await market.getPrice(1)).toString()).to.equal(price.toString());
//     await market.connect(accounts[1]).buy(1, 1, { value: price });
//     expect(await nft.ownerOf(tokenId)).to.equal(await accounts[1].getAddress());

//     let fee = price.mul(feePoints).div(100);
//     expect(await provider.getBalance(feeRecipients[0][0])).to.equal(
//       fee.mul(feeRecipients[0][1]).div(100),
//     );
//     expect(await provider.getBalance(feeRecipients[1][0])).to.equal(
//       fee
//         .mul(feeRecipients[1][1])
//         .div(100)
//         .add(price.sub(fee).mul(saleRecipients[0][1]).div(100)),
//     );
//     price = price.mul(2);
//     await market
//       .connect(accounts[1])
//       .createSellOrder(nft.address, tokenId, price, 1, 721);

//     let feeBalance = await provider.getBalance(feeRecipients[0][0]);
//     await market.connect(accounts[2]).buy(2, 1, { value: price });
//     fee = price.mul(feePoints).div(100);
//     expect(
//       (await provider.getBalance(feeRecipients[0][0])).sub(feeBalance),
//     ).to.equal(fee.mul(feeRecipients[0][1]).div(100));
//   });

//   // it('1155', async function () {
//   //   const account = await accounts[0].getAddress();
//   //   const address = nft1155.address;
//   //   let res = await (await nft1155.mint(account, 10, url)).wait();
//   //   const tokenId = res.events[0].args.id;
//   //   let price = utils.parseEther('1');
//   //   res = await (
//   //     await market.createSellOrder(address, tokenId, price, 1, 1155)
//   //   ).wait();
//   //   let orderId = res.events[0].args.itemId;
//   //   // expect((await market.getPrice(address, tokenId)).toString()).to.equal(
//   //   //   price.toString(),
//   //   // );
//   //   await market.connect(accounts[1]).buy(orderId, 1, { value: price });
//   //   // expect(await nft.ownerOf(tokenId)).to.equal(await accounts[1].getAddress());
//   //   res = await (
//   //     await market
//   //       .connect(accounts[1])
//   //       .createSellOrder(address, tokenId, price, 1, 1155)
//   //   ).wait();
//   //   orderId = res.events[0].args.itemId;
//   //   console.log(orderId);
//   //   await market.connect(accounts[2]).buy(orderId, 1, { value: price });
//   // });
// });
