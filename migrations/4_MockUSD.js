const MockUSD = artifacts.require("MockUSD");
const fs = require("fs");

module.exports = async function (deployer, network) {
  // Read the addressList
  const addressList = JSON.parse(fs.readFileSync("address.json"));

  // Deployment
  await deployer.deploy(MockUSD);

  // Store the address
  addressList[network].MockUSD = MockUSD.address;
  fs.writeFileSync("address.json", JSON.stringify(addressList, null, "\t"));
};
