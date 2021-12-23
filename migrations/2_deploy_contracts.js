const Tile = artifacts.require("./Tile.sol");
const TileFactory = artifacts.require("./TileFactory.sol");

// If you want to hardcode what deploys, comment out process.env.X and use
// true/false;
const DEPLOY_ALL = process.env.DEPLOY_ALL;
const DEPLOY_TILES_FACTORY_CONTRACT = process.env.DEPLOY_TILES_FACTORY_CONTRACT || DEPLOY_ALL;
// Note that we will default to this unless DEPLOY_ACCESSORIES is set.
// This is to keep the historical behavior of this migration.
const DEPLOY_TILES_CONTRACT = process.env.DEPLOY_TILES_CONTRACT || DEPLOY_TILES_FACTORY_CONTRACT || DEPLOY_ALL;

module.exports = async (deployer, network, addresses) => {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress = "";
  if (network === 'rinkeby') {
    proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }

  if (DEPLOY_TILES_CONTRACT) {
    await deployer.deploy(Tile, proxyRegistryAddress, {gas: 5000000});
  }

  if (DEPLOY_TILES_FACTORY_CONTRACT) {
    await deployer.deploy(TileFactory, proxyRegistryAddress, Tile.address, {gas: 7000000});
    const tile = await Tile.deployed();
    await tile.transferOwnership(TileFactory.address);
  }
};
