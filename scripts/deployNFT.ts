import { ethers } from 'hardhat';

async function main() {
  // const NFT = await ethers.getContractFactory('ERC721Tradable');
  // const nft = await NFT.deploy('0x8D380b83956E50686EC7cE80359b93f235d0Dbd4');
  const NFT = await ethers.getContractFactory('Test1155');
  const nft = await NFT.deploy();
  // const NFT = await ethers.getContractFactory('Factory');
  // const nft = await NFT.deploy();
  // await nft.deployed();
  // const feeRecipients = [
  //   ['0x43d6914F10151A3dB15D7aB32bf4c5cD44c48210', 50],
  //   ['0x03c2635bDB921baA8af02A2fF97015109966B24b', 50],
  // ];
  // const saleRecipients = [
  //   ['0x03c2635bDB921baA8af02A2fF97015109966B24b', 30],
  //   ['0xA63543a9ca882CA4584AF26f10E4161D67517358', 70],
  // ];
  // await nft.deploy(
  //   '0x94D93c28277eeaf7F4f4994D679B4639E1a62B20',
  //   saleRecipients,
  //   20,
  //   feeRecipients,
  //   'https://bafybeiglnkyy7ng54fdvtz7pbt7ocx4nq7l4vc7eo7pa76zx4cpens3vgu.ipfs.infura-ipfs.io/',
  //   721,
  // );
  console.log('NFT deployed to:', nft.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
