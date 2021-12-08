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

    const usersInRound = await vault.getTotalUsersInRound(currentRound, {
      from: account,
    });
    console.log("total numbers", parseInt(usersInRound));

    let i = 200;

    // while (i < parseInt(usersInRound)) {
    //   await vault.distributeReward(i, i + 50, { from: account });
    //   console.log(i, i + 50);
    //   i += 50;
    // }

    // await vault.distributeReward(150, 200, { from: account });

    callback(true);
  } catch (err) {
    callback(err);
  }
};
