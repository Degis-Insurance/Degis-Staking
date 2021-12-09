const Web3 = require("web3");

require("babel-register");
// require("babel-polyfill");
const HDWalletProvider = require("@truffle/hdwallet-provider");

//
// const fs = require('fs');
// const mnemonic = fs.readFileSync(".secret").toString().trim();
const dotenv = require("dotenv");
const result = dotenv.config();
if (result.error) {
  throw result.error;
}
// console.log(result.parsed);
var mnemonic = process.env.mnemonic;
var infuraKey = process.env.infuraKey;
var phrase_fuji = process.env.phrase;

const fuji_provider = new Web3.providers.HttpProvider(
  `https://api.avax-test.network/ext/bc/C/rpc`
);

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

  networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache-cli, geth or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    //
    dev: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 8545, // Standard Ethereum port (default: none)
      network_id: "*", // Any network (default: none)
    },
    rinkeby: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          "wss://rinkeby.infura.io/ws/v3/" + infuraKey
        ),
      network_id: 4, // Rinkeby's id
      gas: 5500000, // Ropsten has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      networkCheckTimeout: 1000000000,
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },

    fuji: {
      provider: () => {
        return new HDWalletProvider({
          mnemonic: {
            phrase: phrase_fuji,
          },
          numberOfAddresses: 1,
          shareNonce: true,
          providerOrUrl: fuji_provider,
        });
      },
      network_id: "*",
      timeoutBlocks: 50000,
      skipDryRun: true,
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.9", // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200,
        },
        // evmVersion: "istan",
      },
      // }
    },
  },
};
