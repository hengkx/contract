import { artifacts, ethers } from 'hardhat';

const url =
  'https://4chdy7nzhyneeemy5zgnudwqzkp37zt4rfxwpc7ybv5ie5qsme7a.arweave.net/4I48fbk-GkIRmO5M2g7Qyp-_5nyJb2eL-A16gnYSYT4';

async function main() {
  // const NFT = await ethers.getContractFactory('ERC721Tradable');
  // const nft = await NFT.deploy('0x8D380b83956E50686EC7cE80359b93f235d0Dbd4');
  // const NFT = await ethers.getContractFactory('MarketV2');
  // const nft = await NFT.deploy();
  const Factory = await ethers.getContractFactory('Factory');
  const factory = await Factory.deploy();
  await factory.deployed();
  console.log('Factory deployed to:', factory.address);
  const feeRecipients = [
    ['0x43d6914F10151A3dB15D7aB32bf4c5cD44c48210', 50],
    ['0x03c2635bDB921baA8af02A2fF97015109966B24b', 50],
  ];
  const saleRecipients = [
    ['0x03c2635bDB921baA8af02A2fF97015109966B24b', 30],
    ['0xA63543a9ca882CA4584AF26f10E4161D67517358', 70],
  ];
  let res = await factory.deploy(
    '0xa39b1Ade646eA8a17e4bf05cD0C58452050f87D3',
    saleRecipients,
    20,
    feeRecipients,
    'https://bafybeiglnkyy7ng54fdvtz7pbt7ocx4nq7l4vc7eo7pa76zx4cpens3vgu.ipfs.infura-ipfs.io/',
    721,
  );
  res = await res.wait();
  console.log(res.events[1].args);
  const tokenAddress = res.events[1].args[0];
  console.log(tokenAddress);
  const accounts = await ethers.getSigners();
  // const nft = new ethers.Contract(
  //   tokenAddress,
  //   artifacts.readArtifactSync('ERC721Tradable').abi,
  //   accounts[0],
  // );
  // await nft.mint(1, '0x9454c9090074e7377ed6f8645708Dd529B3b0C15', url);
  await factory.mint(
    tokenAddress,
    '0x9454c9090074e7377ed6f8645708Dd529B3b0C15',
    url,
    1,
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
