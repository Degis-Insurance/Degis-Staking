const Vault = artifacts.require("PurchaseIncentiveVault");

const fs = require("fs");

module.exports = async function (deployer) {
  const addressList = JSON.parse(fs.readFileSync("address.json"));

  const buyerToken_add = addressList.BuyerToken;
  const degisToken_add = addressList.DegisToken;

  await deployer.deploy(Vault, buyerToken_add, degisToken_add);

  addressList.PurchaseIncentiveVault = Vault.address;

  fs.writeFileSync("address.json", JSON.stringify(addressList, null, "\t"));
};
