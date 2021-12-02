const BuyerToken = artifacts.require("BuyerToken");
const Vault = artifacts.require("PurchaseIncentiveVault");
const DegisToken = artifacts.require("DegisToken");

const router = "0xDc5f05ff3188570207f054B9751ba87Cb1488CcD";
const farmingPool = "0x4Ad65338B774b0571d2eD9c8012556126a874262";

module.exports = async (callback) => {
  try {
    const accounts = await web3.eth.getAccounts();
    const account = accounts[0];

    const buyertoken = await BuyerToken.deployed();
    console.log("buyer token address:", buyertoken.address);

    const vault = await Vault.deployed();
    console.log("vault address:", vault.address);

    const degis = await DegisToken.deployed();

    // await buyertoken.addMinter(vault.address, { from: account });

    // await buyertoken.addMinter(router, { from: account });

    await degis.addMinter(farmingPool, { from: account });

    callback(true);
  } catch (err) {
    callback(err);
  }
};
