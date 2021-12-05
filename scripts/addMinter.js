const BuyerToken = artifacts.require("BuyerToken");
const Vault = artifacts.require("PurchaseIncentiveVault");
const DegisToken = artifacts.require("DegisToken");

const router = "0xDc5f05ff3188570207f054B9751ba87Cb1488CcD";
const farmingPool = "0xC3E497a38C62B66620e21F9E7Ca2180d8Cd6716B";
const policyFlow = "0x19145b0AcFC8F38F59822Be268Ee636A5C055281";

const degis_add = "0x6d3036117de5855e1ecd338838FF9e275009eAc2";
const buyer_add = "0x876431DAE3c10273F7B58567419eb40157CcA9Eb";

const fs = require("fs");

module.exports = async (callback) => {
  try {
    const accounts = await web3.eth.getAccounts();
    const account = accounts[0];

    const addressList = JSON.parse(fs.readFileSync("address.json"));

    const buyertoken = await BuyerToken.at(addressList.BuyerToken);
    console.log("buyer token address:", buyertoken.address);

    const vault = await Vault.at(addressList.PurchaseIncentiveVault);
    console.log("vault address:", vault.address);

    const degis = await DegisToken.at(addressList.DegisToken);

    //await buyertoken.addMinter(vault.address, { from: account });

    // await buyertoken.addMinter(policyFlow, { from: account });

    // await degis.addMinter(farmingPool, { from: account });

    callback(true);
  } catch (err) {
    callback(err);
  }
};
