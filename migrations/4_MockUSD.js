const MockUSD = artifacts.require("MockUSD");
const fs = require("fs");

module.exports = async function (deployer, network) {
  const addressList = JSON.parse(fs.readFileSync("address.json"));

  await deployer.deploy(MockUSD);

  addressList.MockUSD = MockUSD.address;

  fs.writeFileSync("address.json", JSON.stringify(addressList, null, "\t"));
};
