import { ethers, run } from 'hardhat';

const url =
  'https://4chdy7nzhyneeemy5zgnudwqzkp37zt4rfxwpc7ybv5ie5qsme7a.arweave.net/4I48fbk-GkIRmO5M2g7Qyp-_5nyJb2eL-A16gnYSYT4';

async function main() {
  const Market = await ethers.getContractFactory('Market');
  const market = await Market.deploy();
  // 0xCc9BE95169E21d6527B82d676C5Db98A707c994f
  console.log('Market deployed to:', market.address);
  await market.deployed();
  // await run('verify:verify', {
  //   address: market.address,
  // });
  return;
  const NFT = await ethers.getContractFactory('ERC721Tradable');
  const feeRecipients = [
    ['0x43d6914F10151A3dB15D7aB32bf4c5cD44c48210', 50],
    ['0x03c2635bDB921baA8af02A2fF97015109966B24b', 50],
  ];
  const saleRecipients = [
    ['0x03c2635bDB921baA8af02A2fF97015109966B24b', 30],
    ['0xA63543a9ca882CA4584AF26f10E4161D67517358', 70],
  ];
  const nft = await NFT.deploy(
    market.address,
    saleRecipients,
    20,
    feeRecipients,
    'https://bafybeiglnkyy7ng54fdvtz7pbt7ocx4nq7l4vc7eo7pa76zx4cpens3vgu.ipfs.infura-ipfs.io/',
  );

  console.log('NFT deployed to:', nft.address);

  const NFT1155 = await ethers.getContractFactory('ERC1155Tradable');
  const nft1155 = await NFT1155.deploy(
    market.address,
    saleRecipients,
    20,
    feeRecipients,
    'https://bafybeiglnkyy7ng54fdvtz7pbt7ocx4nq7l4vc7eo7pa76zx4cpens3vgu.ipfs.infura-ipfs.io/',
  );

  console.log('NFT 1155 deployed to:', nft1155.address);
  await nft1155.deployed();
  // await run('verify:verify', {
  //   address: nft.address,
  //   constructorArguments: [
  //     market.address,
  //     saleRecipients,
  //     20,
  //     feeRecipients,
  //     'https://bafybeiglnkyy7ng54fdvtz7pbt7ocx4nq7l4vc7eo7pa76zx4cpens3vgu.ipfs.infura-ipfs.io/',
  //   ],
  // });

  await nft.mint(1, '0x9454c9090074e7377ed6f8645708Dd529B3b0C15', url);
  await nft1155.mint(1, '0x9454c9090074e7377ed6f8645708Dd529B3b0C15', 10, url);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
