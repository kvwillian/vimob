import "mocha";
import { expect, assert } from "chai";
import { describe, it } from "mocha";
import { addBuyer } from "../../src/buyer/addBuyer";
import * as admin from "firebase-admin";

describe("addBuyer", function() {
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

  it("Should take a existing buyer", async () => {
    await addBuyer(
      { externalId: "buyerExternalIdExist", user: "user-exist" },
      "company-test"
    );

    const buyerCreatedDoc = await admin
      .firestore()
      .collection("buyers")
      .where("user", "==", "user-exist")
      .get();

    const buyer = buyerCreatedDoc.docs[0].data();

    expect(buyer).to.be.deep.equals({
      company: {
        id: "company-test",
        name: "company-test"
      },
      externalId: "buyerExternalIdExist",
      user: "user-exist"
    });
  });

  it("Should add a null user", async () => {
    await addBuyer(
      { externalId: "buyerExternalIdExist", user: null },
      "company-test"
    );

    const buyerCreatedDoc = await admin
      .firestore()
      .collection("buyers")
      .where("user", "==", "user-exist")
      .get();

    const buyer = buyerCreatedDoc.docs[0].data();

    expect(buyer).to.be.deep.equals({
      company: {
        id: "company-test",
        name: "company-test"
      },
      externalId: "buyerExternalIdExist",
      user: "user-exist"
    });
  });

  it("Should show error because company doesn't exist", async () => {
    try {
      await addBuyer(
        { externalId: "buyerExternalId", user: "user-test" },
        "fakeCompanyId"
      );
    } catch (error) {
      expect(error.message).to.be.deep.equals("Unauthenticated user");
    }
  });

  it("Should create buyer", async () => {
    await addBuyer(
      { externalId: "buyerExternalId", user: "user-test" },
      "company-test"
    );

    const buyerCreatedDoc = await admin
      .firestore()
      .collection("buyers")
      .where("user", "==", "user-test")
      .get();

    const buyer = buyerCreatedDoc.docs[0].data();

    expect(buyer).to.be.deep.equals({
      company: {
        id: "company-test",
        name: "company-test"
      },
      externalId: "buyerExternalId",
      user: "user-test"
    });
  });

  it("Should return null", async () => {
    const result = await addBuyer({}, "company-test");

    expect(result).to.be.deep.equals(null);
  });

  async function cleanUp() {
    const buyerCreatedDoc = await admin
      .firestore()
      .collection("buyers")
      .where("user", "==", "user-test")
      .get();
    if (!buyerCreatedDoc.empty) {
      await admin
        .firestore()
        .collection("buyers")
        .doc(buyerCreatedDoc.docs[0].id)
        .delete();
    }
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
        user: "buyer-test"
      });
  }
});
