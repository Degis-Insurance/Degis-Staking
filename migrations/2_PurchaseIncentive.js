const BuyerToken = artifacts.require("BuyerToken");
const vault = artifacts.require("PurchaseIncentiveVault");
const DegisToken = artifacts.require("DegisToken");
const MockUSD = artifacts.require("MockUSD");

const fs = require("fs");

module.exports = async function (deployer) {
  await deployer.deploy(BuyerToken);

  await deployer.deploy(MockUSD);

  await deployer.deploy(DegisToken);

  await deployer.deploy(vault, BuyerToken.address, DegisToken.address);

  const addressList = {
    BuyerToken: BuyerToken.address,
    DegisToken: DegisToken.address,
    PurchaseIncentiveVault: vault.address,
    MockUSD: MockUSD.address,
  };

  const data = JSON.stringify(addressList, null, "\t");

  fs.writeFile("address.json", data, (err) => {
    if (err) {
      throw err;
    }
  });

  // await deployer.deploy(
  //   NaughtyProxy,
  //   PolicyCore.address,
  //   NaughtyRouter.address
  // );
};
