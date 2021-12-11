import { ethers } from 'hardhat';

const market = '0xef79615C58C5aEaF137d9A16f54349163e3688FC';
const nftAddress = '0x8e022E73cF067532810bf3FA6E1216E2709fb488';
const url =
  'https://4chdy7nzhyneeemy5zgnudwqzkp37zt4rfxwpc7ybv5ie5qsme7a.arweave.net/4I48fbk-GkIRmO5M2g7Qyp-_5nyJb2eL-A16gnYSYT4';

async function main() {
  const Market = await ethers.getContractFactory('Market');
  const contract = Market.attach(market);
  await contract.buy(
    nftAddress,
    1,
    '0x9454c9090074e7377ed6f8645708Dd529B3b0C15',
    '0x5b3f047a7Db07fC6F545816F13dFC3DbC8Adb2DB',
  );
  console.log('NFT minted:', contract);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
