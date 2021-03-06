const PurchaseIncentiveVault = artifacts.require("PurchaseIncentiveVault");
const fs = require("fs");

module.exports = async function (deployer, network, accounts) {
  // Read the addressList
  const addressList = JSON.parse(fs.readFileSync("address.json"));

  const buyerToken_address = addressList[network].BuyerToken;
  const degisToken_address = addressList[network].DegisToken;

  // Deployment
  await deployer.deploy(
    PurchaseIncentiveVault,
    buyerToken_address,
    degisToken_address
  );

  // Store the address
  addressList[network].PurchaseIncentiveVault = PurchaseIncentiveVault.address;
  addressList[network].deployerAddress = accounts[0];
  fs.writeFileSync("address.json", JSON.stringify(addressList, null, "\t"));
};
