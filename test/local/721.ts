import { ethers, waffle } from 'hardhat';
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

describe('ERC721Tradable', function () {
  let accounts: Signer[];
  let market: Contract;
  let nft: Contract;
  let nft1155: Contract;

  beforeEach(async function () {
    accounts = await ethers.getSigners();
    const Market = await ethers.getContractFactory('Market');
    market = await Market.deploy();
    const NFT = await ethers.getContractFactory('ERC721Tradable');
    nft = await NFT.deploy(
      market.address,
      saleRecipients,
      feePoints,
      feeRecipients,
      '',
    );
  });

  it('only owner pause or unpause', async function () {
    await nft.connect(accounts[0]).pause();
    expect(await nft.paused()).to.true;
    await nft.connect(accounts[0]).unpause();
    expect(await nft.paused()).to.false;
    await expect(nft.connect(accounts[1]).pause()).to.reverted;
    expect(await nft.paused()).to.false;
  });
});
