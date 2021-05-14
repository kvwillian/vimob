import {
  CallableContext,
  HttpsError
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function modifyStatusUnitFunction(
  data: any,
  context: CallableContext
) {
  const db = admin.firestore();
  const company = await db
    .collection("companies")
    .doc(context.auth.uid)
    .get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }
  try {
    if (!data) {
      console.log("modifyStatusUnitFunction data:", data);
      return null;
    }
    const statuses = await db
      .collection("company-statuses")
      .where("company.id", "==", company.id)
      .get();
    const companyStatuses = statuses.docs[0];

    const unit = await admin
      .firestore()
      .collection("units")
      .where("company.id", "==", company.id)
      .where("development.externalId", "==", data.development.externalId)
      .where("block.externalId", "==", data.block.externalId)
      .where("externalId", "==", data.externalId)
      .get();

    const docRefUnit = unit.docs[0].ref;
    const status = companyStatuses.data().units[`${data.status}`];
    const newStatus = {
      [`${data.status}`]: {
        available: data.status == "available" ? true : false,
        ...status,
        statusText: data.status
      }
    };

    await docRefUnit.update({ status: { ...newStatus } });

    // development-unit
    const developmentUnit = await admin
      .firestore()
      .collection("development-units")
      .where("company.id", "==", company.id)
      .where("development.externalId", "==", data.development.externalId)
      .get();

    let blocks = developmentUnit.docs[0].data().blocks;
    const blockIndex = blocks.findIndex(
      b => b.externalId == data.block.externalId
    );
    const unitIndex = blocks[blockIndex].units.findIndex(
      u => u.externalId == data.externalId
    );
    blocks[blockIndex].units[unitIndex].status = data.status;

    return await developmentUnit.docs[0].ref.update({
      blocks: blocks
    });
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
