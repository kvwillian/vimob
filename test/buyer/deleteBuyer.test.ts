import "mocha";
import { expect, assert } from "chai";
import { describe, it } from "mocha";
import { deleteBuyer } from "../../src/buyer/deleteBuyer";
import * as admin from "firebase-admin";

describe("deleteBuyer", function() {
  before(async () => {
    admin.initializeApp();
    //clean
    await cleanUp();
    //create
    await createCompany();
    await createBuyer();
  });

  after(async () => {
    //clean
    await cleanUp();
    for (const app of admin.apps) {
      await app.delete();
    }
  });

  it("Should throw error because company doesn't exist", async () => {
    try {
      await deleteBuyer("", "non-existing-company");
    } catch (error) {
      expect(error.message).to.be.deep.equals("Unauthenticated user");
    }
  });

  it("Should delete buyer", async () => {
    await deleteBuyer("buyer-externalId", "company-test");

    const deletedBuyerDoc = await admin
      .firestore()
      .collection("buyers")
      .doc("buyer-test")
      .get();

    expect(deletedBuyerDoc.exists).to.be.deep.equals(false);
  });

  async function cleanUp() {
    await admin
      .firestore()
      .collection("companies")
      .doc("company-test")
      .delete();
    await admin
      .firestore()
      .collection("buyers")
      .doc("buyer-test")
      .delete();
  }
  async function createCompany() {
    await admin
      .firestore()
      .collection("companies")
      .doc("company-test")
      .set({
        cnpj: "90.145.502/00010-1",
        name: "company-test"
      });
  }
  async function createBuyer() {
    await admin
      .firestore()
      .collection("buyers")
      .doc("buyer-test")
      .set({
        company: { id: "company-test" },
        externalId: "buyer-externalId",
        user: "buyer-test"
      });
  }
});
