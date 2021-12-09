const MockUSD = artifacts.require("MockUSD");
const fs = require("fs");

module.exports = async function (deployer, network, accounts) {
  // Read the addressList
  const addressList = JSON.parse(fs.readFileSync("address.json"));

  // Deployment
  await deployer.deploy(MockUSD);

  // Store the address
  addressList[network].MockUSD = MockUSD.address;
  addressList[network].deployerAddress = accounts[0];
  fs.writeFileSync("address.json", JSON.stringify(addressList, null, "\t"));
};
