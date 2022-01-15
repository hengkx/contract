import { ethers, run } from 'hardhat';

async function main() {
  const ProxyRegistry = await ethers.getContractFactory('ProxyRegistry');
  const proxy = await ProxyRegistry.deploy();
  console.log('ProxyRegistry deployed to:', proxy.address);
  await proxy.deployed();
  // await run('verify:verify', {
  //   address: proxy.address,
  // });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
