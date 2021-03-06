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

    await buyertoken.mint(account, web3.utils.toWei("2000", "ether"), {
      from: account,
    });
    const balance = await buyertoken.balanceOf(account);
    console.log("user balance:", parseInt(balance / 1e18));

    await vault.stakeBuyerToken(web3.utils.toWei("20", "ether"), {
      from: account,
    });

    callback(true);
  } catch (err) {
    callback(err);
  }
};
