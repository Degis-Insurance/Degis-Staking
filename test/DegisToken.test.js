import chai, { expect } from "chai";
import chaiAsPromised from "chai-as-promised";
import { tokens, number, ether, ZERO_ADD, EVM_REVERT, wait } from "./helpers";

import { expectEvent, expectRevert } from "@openzeppelin/test-helpers";

chai.use(chaiAsPromised);
chai.should();

const DegisToken = artifacts.require("DegisToken");

contract("DegisToken", async (accounts) => {
  const dev_account = accounts[0];
  let degis;

  before(async () => {
    degis = await DegisToken.deployed();
  });

  describe("Basic Function Testing...", async () => {
    it("should set the deployer as the owner", async () => {
      const owner = await degis.owner.call();
      expect(owner).to.be.eq(dev_account);
    });

    it("should put the owner into the minter list", async () => {
      const isInMinterList = await degis.isMinter.call(dev_account);
      assert.equal(isInMinterList, true);
    });

    it("should have a cap of 100 million", async () => {
      const degis = await DegisToken.deployed();
      const cap = await degis.CAP.call();
      assert.equal(number(cap), 100000000);
    });
  });

  describe("Advanced Function Testing...", async () => {
    it("should add a minter", async () => {
      const receipt = await degis.addMinter(accounts[1], { from: dev_account });

      expectEvent(receipt, "MinterAdded", {
        _newMinter: accounts[1],
      });
    });

    it("should remove a minter", async () => {
      const receipt = await degis.removeMinter(accounts[1], {
        from: dev_account,
      });

      expectEvent(receipt, "MinterRemoved", {
        _oldMinter: accounts[1],
      });
    });

    it("should not mint more than the cap", async () => {
      // Or use: (eventually can be removed)
      // expect (degis.mint(address, amount, {from: dev_account,})
      //  .to.be.eventually.rejectedWith(err_msg);

      // expectRevert(
      //   degis.mint(accounts[1], ether(1e10), {
      //     from: dev_account,
      //   }),
      //   err_msg
      // );

      degis
        .mint(accounts[1], ether(1e10), {
          from: dev_account,
        })
        .should.be.rejectedWith("DegisToken exceeds the cap (100 million)");
    });

    it("should not be minted by a user who are not in the minter list", async () => {
      degis
        .mint(accounts[1], ether(1e3), { from: accounts[3] })
        .should.be.rejectedWith(
          "Only the address in the minter list can call this function"
        );
    });

    it("should mint some tokens successfully", async () => {
      degis
        .mint(dev_account, ether(1e3), { from: dev_account })
        .then((receipt) => {
          expectEvent(receipt, "Mint", {
            _account: dev_account,
          });

          degis.balanceOf(dev_account).then((balance) => {
            expect(balance).to.be.eq(ether(1e3));
          });
        });
    });

    it("should burn some tokens successfully", async () => {
      degis.burn(dev_account, ether(1e3), { from: dev_account }).then(() => {
        degis.balanceOf(dev_account).then((balance) => {
          expect(balance).to.be.eq(0);
        });
      });
    });

    it("should transfer the ownership to a new address", async () => {
      degis.passOwnership(accounts[1], { from: dev_account }).then(() => {
        degis.owner.call().then((new_owner) => {
          expect(new_owner).to.be.eq(new_account);
        });
      });
    });
  });
});
