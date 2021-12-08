import { expect } from "chai";
import {
  tokens,
  number,
  ether,
  ETHER_ADDRESS,
  EVM_REVERT,
  wait,
} from "./helpers";

require("chai").use(require("chai-as-promised")).should();

const DegisToken = artifacts.require("DegisToken");

contract("Degis Token Testing...", async (accounts) => {
  const dev_account = accounts[0];
  let degis;

  before(async () => {
    degis = await DegisToken.deployed();
  });

  it("should set the deployer as the owner", async () => {
    const owner = await degis.owner.call();
    // assert.equal(owner, dev_account);

    expect(owner).to.be.eq(dev_account);
  });

  it("should put the owner into the minter list", async () => {
    const isInMinterList = await degis.isMinter.call(dev_account);
    assert.equal(isInMinterList, true);
  });

  it("should have a cap of 100 million", async () => {
    const cap = await degis.CAP.call();
    assert.equal(number(cap), 100000000);
  });

  it("should not mint more than the cap", async () => {
    const err_msg = "DegisToken exceeds the cap (100 million)";

    // Or use: (eventually can be removed)
    // expect (degis.mint(address, amount, {from: dev_account,})
    //  .to.be.eventually.rejectedWith(err_msg);
    degis
      .mint(accounts[1], ether(1e10), {
        from: dev_account,
      })
      .should.be.rejectedWith(err_msg);
  });
});
