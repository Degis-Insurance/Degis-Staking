const BuyerToken = artifacts.require("BuyerToken");
const fs = require("fs");

module.exports = async function (deployer, network) {
  // Read the addressList
  const addressList = JSON.parse(fs.readFileSync("address.json"));

  // Deployment
  await deployer.deploy(BuyerToken);

  // Store the address
  addressList[network].BuyerToken = BuyerToken.address;
  fs.writeFileSync("address.json", JSON.stringify(addressList, null, "\t"));
};
