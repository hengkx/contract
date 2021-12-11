import { ethers } from 'hardhat';

async function main() {
  const Market = await ethers.getContractFactory('Market');
  const market = await Market.deploy();

  console.log('Market deployed to:', market.address);

  const NFT = await ethers.getContractFactory('ERC721Tradable');
  const nft = await NFT.deploy(market.address);

  console.log('NFT deployed to:', nft.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
