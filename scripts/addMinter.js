const BuyerToken = artifacts.require("BuyerToken");
const Vault = artifacts.require("PurchaseIncentiveVault");
const DegisToken = artifacts.require("DegisToken");

const router = "0xf661C2C9031e6549Fb1990A08d9eeAe63Db46e29";
const farmingPool = "0x7C824EC3eff695ffbBBb44410144fDeB00862A69";
const policyFlow = "0xfAa5961cE2090C7cc5602AA7bDA75401bD47fB32";

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

    await degis.addMinter(vault.address, { from: account });

    // await buyertoken.addMinter(policyFlow, { from: account });

    //await buyertoken.addMinter(router, { from: account });

    // await degis.addMinter(farmingPool, { from: account });

    callback(true);
  } catch (err) {
    callback(err);
  }
};
