const { ethers } = require('hardhat');

async function main() {
  const Bank = await ethers.getContractFactory('Bank');
  const bank = await Bank.deploy();
  await bank.waitForDeployment();

  console.log('Bank address:', bank.getAddress());
}

main();
