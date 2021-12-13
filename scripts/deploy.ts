import { ethers } from 'hardhat';

async function main() {
  const Market = await ethers.getContractFactory('Market');
  const market = await Market.deploy();
  // 0xCc9BE95169E21d6527B82d676C5Db98A707c994f
  console.log('Market deployed to:', market.address);

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
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
