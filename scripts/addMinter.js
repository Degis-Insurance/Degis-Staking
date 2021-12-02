const BuyerToken = artifacts.require("BuyerToken");
const Vault = artifacts.require("PurchaseIncentiveVault");

const router = "0x040084c7e4a0AA6B4Ac21FaC0AeF1C3928E57Aa9";

module.exports = async (callback) => {
  try {
    const accounts = await web3.eth.getAccounts();
    const account = accounts[0];

    const buyertoken = await BuyerToken.deployed();
    console.log("buyer token address:", buyertoken.address);

    const vault = await Vault.deployed();
    console.log("vault address:", vault.address);

    // await buyertoken.addMinter(vault.address, { from: account });

    await buyertoken.addMinter(router, { from: account });

    callback(true);
  } catch (err) {
    callback(err);
  }
};
