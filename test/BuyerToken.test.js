const {
  BN,
  constants,
  expectEvent,
  expectRevert,
} = require("@openzeppelin/test-helpers");

import { expect } from "chai";

const BuyerToken = artifacts.require("BuyerToken");

contract("BuyerToken", async (accounts) => {
  const dev_account = accounts[0];
  let buyerToken;

  before(async () => {
    buyerToken = await BuyerToken.delpoyed();
  });

  describe("Basic Function Testing...", async () => {
    it("reverts when transferring tokens to the zero address", async function () {
      let value = new BN(1);

      buyerToken
        .transfer(constants.ZERO_ADDRESS, value, {
          from: dev_account,
        })
        .then((promise) => {
          expectRevert(promise, "ERC20: transfer to the zero address");
        });
    });
    it("should have correct name and symbol"),
      async function () {
        console.log(buyerToken.address);
        let ins = await BuyerToken.deployed();
        ins.owner.call().then((isMinter) => {
          expect(isMinter).to.be.eq(dev_account);
        });
      };
  });
});
