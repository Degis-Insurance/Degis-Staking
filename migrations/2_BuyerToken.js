const BuyerToken = artifacts.require("BuyerToken");
const fs = require("fs");

module.exports = async function (deployer, network) {
  const addressList = JSON.parse(fs.readFileSync("address.json"));

  await deployer.deploy(BuyerToken);

  addressList.BuyerToken = BuyerToken.address;

  fs.writeFileSync("address.json", JSON.stringify(addressList, null, "\t"));
};
