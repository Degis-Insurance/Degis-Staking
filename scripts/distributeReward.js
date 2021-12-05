const BuyerToken = artifacts.require("BuyerToken");
const Vault = artifacts.require("PurchaseIncentiveVault");

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

    const currentRound = await vault.currentRound.call();
    console.log("currentRound:", parseInt(currentRound));

    await vault.distributeReward(0, 5, { from: account });

    callback(true);
  } catch (err) {
    callback(err);
  }
};
