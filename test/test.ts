import { ethers } from 'hardhat';
import { Signer } from 'ethers';
import { expect } from 'chai';
import ERC721Tradable from '../artifacts/contracts/ERC721Tradable.sol/ERC721Tradable.json';

const market = '0xef79615C58C5aEaF137d9A16f54349163e3688FC';

const nftAddress = '0x8e022E73cF067532810bf3FA6E1216E2709fb488';

const url =
  'https://4chdy7nzhyneeemy5zgnudwqzkp37zt4rfxwpc7ybv5ie5qsme7a.arweave.net/4I48fbk-GkIRmO5M2g7Qyp-_5nyJb2eL-A16gnYSYT4';

describe('Token', function () {
  let accounts: Signer[];

  beforeEach(async function () {
    accounts = await ethers.getSigners();
  });

  it('It should deploy the contract, mint a token, and resolve to the right URI', async function () {
    // const NFT = await ethers.getContractFactory('MyNFT');
    // const nft = await NFT.deploy();
    const nft = new ethers.Contract(nftAddress, ERC721Tradable.abi);
    const URI = url;
    await nft.mint('0x9454c9090074e7377ed6f8645708Dd529B3b0C15', URI);
    expect(await nft.tokenURI(1)).to.equal(URI);
    // Do something with the accounts
  });
});
