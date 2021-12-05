const PurchaseIncentiveVault = artifacts.require("PurchaseIncentiveVault");

// Args:
// --reward (degis reward per round)
// --interval (reward interval)
const args = require("minimist")(process.argv.slice(2));

module.exports = async (callback) => {
  try {
    const accounts = await web3.eth.getAccounts();
    const account = await accounts[0];

    const vault = await PurchaseIncentiveVault.deployed();
    console.log("vault address:", vault.address);

    // 100 blocks can settle
    await vault.setDistributionInterval(args["interval"], {
      from: account,
    });

    console.log(args["reward"]);

    const degisPerRound = web3.utils.toWei(args["reward"].toString(), "ether");
    await vault.setDegisPerRound(degisPerRound, { from: account });

    callback(true);
  } catch (err) {
    callback(err);
  }
};
