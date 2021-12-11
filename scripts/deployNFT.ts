import { ethers } from 'hardhat';

async function main() {
  const NFT = await ethers.getContractFactory('ERC721Tradable');
  const nft = await NFT.deploy('0x8D380b83956E50686EC7cE80359b93f235d0Dbd4');

  console.log('NFT deployed to:', nft.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
