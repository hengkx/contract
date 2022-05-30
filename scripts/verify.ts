import { run } from 'hardhat';

async function main() {
  await run('verify:verify', {
    address: '0x612eb75f61446c8c9730889ff02a082976b0056f',
  });
  return;
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
