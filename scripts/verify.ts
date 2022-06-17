import { ethers, run } from 'hardhat';

async function main() {
  // const Market = await ethers.getContractFactory('Market');
  // const market = await Market.deploy();
  // // 0xCc9BE95169E21d6527B82d676C5Db98A707c994f
  // console.log('Market deployed to:', market.address);
  // await market.deployed();

  await run('verify:verify', {
    address: '0xCc9BE95169E21d6527B82d676C5Db98A707c994f',
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
    address: '0x3AC10d0C8ec2bfb7a00900c67A8b460894E3643E',
    constructorArguments: [
      'Unbalanced',
      'HUX',
      '0x78A1AEa5fAbD2078354CeBd4925F50B0C5D805aE',
      [
        ['0x5FF52F93104684c799a8B78f90e6cA324B2d1d5d', 90],
        ['0x64C1D3bDA744010c1c07eaCa94B31Eab448A07A4', 10],
      ],
      10,
      [
        ['0x5FF52F93104684c799a8B78f90e6cA324B2d1d5d', 90],
        ['0x64C1D3bDA744010c1c07eaCa94B31Eab448A07A4', 10],
      ],
      'https://arweave.net/2knjR5WylHv0MhnoBSAIdgD1GliF0SGV1_9DRSLwwAE',
    ],
    // libraries: {
    //   ProxyRegistry:
    //     '0x608060405234801561001057600080fd5b5061002d61002261003260201b60201c565b61003a60201b60201c565b6100fe565b600033905090565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050816000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a35050565b6107818061010d6000396000f3fe608060405234801561001057600080fd5b50600436106100625760003560e01c8063715018a6146100675780638da5cb5b14610071578063c45527911461008f578063d7b72010146100bf578063e4a21ff6146100db578063f2fde38b146100f7575b600080fd5b61006f610113565b005b61007961019b565b60405161008691906105f2565b60405180910390f35b6100a960048036038101906100a49190610561565b6101c4565b6040516100b6919061060d565b60405180910390f35b6100d960048036038101906100d49190610561565b6101e4565b005b6100f560048036038101906100f09190610561565b6102ba565b005b610111600480360381019061010c9190610561565b610388565b005b61011b610480565b73ffffffffffffffffffffffffffffffffffffffff1661013961019b565b73ffffffffffffffffffffffffffffffffffffffff161461018f576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161018690610648565b60405180910390fd5b6101996000610488565b565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905090565b60016020528060005260406000206000915054906101000a900460ff1681565b6101ec610480565b73ffffffffffffffffffffffffffffffffffffffff1661020a61019b565b73ffffffffffffffffffffffffffffffffffffffff1614610260576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161025790610648565b60405180910390fd5b60018060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548160ff02191690831515021790555050565b6102c2610480565b73ffffffffffffffffffffffffffffffffffffffff166102e061019b565b73ffffffffffffffffffffffffffffffffffffffff1614610336576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161032d90610648565b60405180910390fd5b600160008273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81549060ff021916905550565b610390610480565b73ffffffffffffffffffffffffffffffffffffffff166103ae61019b565b73ffffffffffffffffffffffffffffffffffffffff1614610404576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016103fb90610648565b60405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff161415610474576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161046b90610628565b60405180910390fd5b61047d81610488565b50565b600033905090565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050816000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a35050565b60008135905061055b81610734565b92915050565b600060208284031215610577576105766106b7565b5b60006105858482850161054c565b91505092915050565b61059781610679565b82525050565b6105a68161068b565b82525050565b60006105b9602683610668565b91506105c4826106bc565b604082019050919050565b60006105dc602083610668565b91506105e78261070b565b602082019050919050565b6000602082019050610607600083018461058e565b92915050565b6000602082019050610622600083018461059d565b92915050565b60006020820190508181036000830152610641816105ac565b9050919050565b60006020820190508181036000830152610661816105cf565b9050919050565b600082825260208201905092915050565b600061068482610697565b9050919050565b60008115159050919050565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b600080fd5b7f4f776e61626c653a206e6577206f776e657220697320746865207a65726f206160008201527f6464726573730000000000000000000000000000000000000000000000000000602082015250565b7f4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e6572600082015250565b61073d81610679565b811461074857600080fd5b5056fea264697066735822122074d712c0e0e7594eecf3a75121d1e632d04745d44bd0e963ebd301d8fbe4394164736f6c63430008070033',
    // },
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
