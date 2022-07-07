// import { ethers, waffle } from 'hardhat';
// import { Contract, Signer, utils } from 'ethers';
// import { expect } from 'chai';

// const provider = waffle.provider;

// describe('Contract', function () {
//   let accounts: Signer[];
//   let market: Contract;
//   let nft: Contract;

//   beforeEach(async function () {
//     accounts = await ethers.getSigners();
//     const NFT = await ethers.getContractFactory('Test1155');
//     nft = await NFT.deploy();
//   });

//   it('test', async function () {
//     const orderHash = await nft.hashToSign('a', 1);
//     console.log('orderHash', orderHash);
//     const sig = [
//       28,
//       '0xf766d876f93fe73575e0b04a6fdfdf66836ef682d063d38b3d756ff93ca65e61',
//       '0x2fda6f18ecb977f03b536c1435a78859697914b4ceb1da347fb9054176e6d364',
//     ];
//     let res = await nft.get('a', 1, sig);
//     console.log(res);
//     res = await nft.getHashPackedMessage(orderHash);
//     console.log('h0', res);
//     res = await nft.getAddress(res, sig);
//     console.log(res);
//     console.log('--------------');
//     // res = await nft.getHashPackedMessage2('a', 1);
//     // console.log('h1', res);
//     // res = await nft.getAddress(res, sig);
//     // console.log(res);
//   });
// });
