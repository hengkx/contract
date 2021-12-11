import { ethers } from 'hardhat';

const nftAddress = '0xDE671154D23E5f2Da762eD270167afC31Be97b11';
const url =
  'https://4chdy7nzhyneeemy5zgnudwqzkp37zt4rfxwpc7ybv5ie5qsme7a.arweave.net/4I48fbk-GkIRmO5M2g7Qyp-_5nyJb2eL-A16gnYSYT4';

async function main() {
  const NFT = await ethers.getContractFactory('ERC721Tradable');
  const contract = NFT.attach(nftAddress);
  await contract.mint('0x9454c9090074e7377ed6f8645708Dd529B3b0C15', url);
  console.log('NFT minted:', contract);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
