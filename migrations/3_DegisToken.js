const DegisToken = artifacts.require("DegisToken");
const fs = require("fs");

module.exports = async function (deployer, network) {
  // Read the addressList
  const addressList = JSON.parse(fs.readFileSync("address.json"));

  // Deployment
  await deployer.deploy(DegisToken);

  // Store the address
  addressList[network].DegisToken = DegisToken.address;
  fs.writeFileSync("address.json", JSON.stringify(addressList, null, "\t"));
};
