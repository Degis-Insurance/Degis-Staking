const DegisToken = artifacts.require("DegisToken");
const fs = require("fs");

module.exports = async function (deployer, network) {
  const addressList = JSON.parse(fs.readFileSync("address.json"));

  await deployer.deploy(DegisToken);

  addressList.DegisToken = DegisToken.address;

  fs.writeFileSync("address.json", JSON.stringify(addressList, null, "\t"));
};
