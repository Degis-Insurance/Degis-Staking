const BuyerToken = artifacts.require("BuyerToken");
const Vault = artifacts.require("PurchaseIncentiveVault");

module.exports = async (callback) => {
  try {
    const accounts = await web3.eth.getAccounts();
    const account = accounts[0];

    const buyertoken = await BuyerToken.deployed();
    console.log("buyer token address:", buyertoken.address);

    const vault = await Vault.deployed();
    console.log("vault address:", vault.address);

    const currentRound = await vault.currentRound.call();
    console.log("currentRound:", parseInt(currentRound));

    await vault.distributeReward(0, 5, { from: account });

    callback(true);
  } catch (err) {
    callback(err);
  }
};
