import { artifacts, ethers } from "hardhat";
import { Contract, Signer, utils } from "ethers";
import { expect } from "chai";

const marketAddress = "0xC81C55d0b04936239983df99880101c41FAB57df";
const nftAddress = "0x396A49921D1002676964Cd7965eb1185354a8d3a";
const nft1155Address = "0xCd5Bf195F037024873cdC410Aa5F010C364FAAa1";

describe("online", function () {
  let accounts: Signer[];
  let market: Contract;
  let nft: Contract;
  let nft1155: Contract;

  beforeEach(async function () {});

  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const [owner, address1] = await ethers.getSigners();
    console.log(
      await owner.getAddress(),
      utils.formatEther(await owner.getBalance()),
    );
    const Test = await ethers.getContractFactory("Test");

    const test = await Test.deploy();
    console.log(test.address);
    await owner.sendTransaction({
      to: test.address,
      value: utils.parseEther("5.0"), // Sends exactly 1.0 ether
    });
    await owner.sendTransaction({
      to: test.address,
      value: utils.parseEther("3.0"), // Sends exactly 1.0 ether
    });
    console.log(await test.getBalance());
    console.log("getTotalIncome", await test.getTotalIncome());
    console.log(
      await address1.getAddress(),
      utils.formatEther(await address1.getBalance()),
    );
    await test.connect(address1).withdraw();
    console.log(
      await address1.getAddress(),
      utils.formatEther(await address1.getBalance()),
    );
    // const ownerBalance = await hardhatToken.balanceOf(owner.address);
    // expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});
