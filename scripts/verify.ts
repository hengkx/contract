import { ethers, run } from 'hardhat';

async function main() {
  // await run('verify:verify', {
  //   address: '0x612eb75f61446c8c9730889ff02a082976b0056f',
  // });
  await run('verify:verify', {
    address: '0x3CDc5aFCA12D499d292d9Db1a62C041703C94f96',
  });
  return;
  // const NFT = await ethers.getContractFactory('ERC721Tradable');
  // const feeRecipients = [['0x9454c9090074e7377ed6f8645708Dd529B3b0C15', 100]];
  // const saleRecipients = [['0x9454c9090074e7377ed6f8645708Dd529B3b0C15', 100]];
  // const nft = await NFT.deploy(
  //   'Culture Vault',
  //   'CV',
  //   '0xa3419F4E537907D14B25295054353eE97c352d17',
  //   saleRecipients,
  //   10,
  //   feeRecipients,
  //   'https://arweave.net/R68IhS3lkZGxelucxTNDM4cmGXVs_VL27k9hvxKpzfo',
  // );
  // console.log(nft.address);
  // return;
  await run('verify:verify', {
    address: '0xCb9EBe3Cc8cf80552650bc3a81AdE5295CC744F7',
    constructorArguments: [
      'Culture Vault',
      'CV',
      '0xa3419F4E537907D14B25295054353eE97c352d17',
      [['0x9454c9090074e7377ed6f8645708Dd529B3b0C15', 100]],
      10,
      [['0x9454c9090074e7377ed6f8645708Dd529B3b0C15', 100]],
      'https://arweave.net/R68IhS3lkZGxelucxTNDM4cmGXVs_VL27k9hvxKpzfo',
    ],
    // constructorArguments: [
    //   'Culture Vault',
    //   'CV',
    //   '0xa3419F4E537907D14B25295054353eE97c352d17',
    //   [
    //     {
    //       recipient: '0x9454c9090074e7377ed6f8645708Dd529B3b0C15',
    //       points: 100,
    //     },
    //   ],
    //   10,
    //   [
    //     {
    //       recipient: '0x9454c9090074e7377ed6f8645708Dd529B3b0C15',
    //       points: 100,
    //     },
    //   ],
    //   'https://arweave.net/R68IhS3lkZGxelucxTNDM4cmGXVs_VL27k9hvxKpzfo',
    // ],
  });
  return;
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
