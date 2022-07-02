const hre = require("hardhat");

//Returns the balance of a given address.
async function getBalance(address) {
  const balanceBigInt = await hre.waffle.provider.getBalance(address);
  return hre.ethers.utils.formatEther(balanceBigInt);
}

async function main() {
  // Get example account.
  const [owner] = await hre.ethers.getSigners();
  const tokenId = 1;

  // Get the contract to deploy and deploy.
  const ChainBattles = await hre.ethers.getContractFactory("ChainBattles");
  const chainBattles = await ChainBattles.deploy();
  await chainBattles.deployed();

  console.log("ChainBattles deployed to ", chainBattles.address);

  console.log("-- start --");
  // Check balances before start.
  console.log(await getBalance(owner.address));

  console.log("-- create new Hero --");
  //Creating a new hero.
  await chainBattles.mint();
  // Print JSON of the hero result.
  console.log(await chainBattles.getSvgForTest(tokenId));
  // Check balances after creating a new hero.
  console.log(await getBalance(owner.address));

  console.log("-- train the hero --");
  // Train our hero
  await chainBattles.train(tokenId);
  // Print JSON of hero result.
  console.log(await chainBattles.getSvgForTest(tokenId));
  // Check balances after training the hero.
  console.log(await getBalance(owner.address));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
