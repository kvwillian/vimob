import {
  CallableContext,
  HttpsError
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function addPaymentPlanFunction(
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
    const payment = await db
      .collection("payment-plans")
      .where("company.id", "==", company.id)
      .where("externalId", "==", data.externalId)
      .get();

    let docRef: FirebaseFirestore.DocumentReference;
    if (payment.empty) {
      docRef = db.collection("payment-plans").doc();
    } else {
      docRef = payment.docs[0].ref;
    }

    //Developments
    const dev = await admin
      .firestore()
      .collection("developments")
      .where("company.id", "==", company.id)
      .get();
    var developments = [];
    if (data.developments != null) {
      data.developments = data.developments.split(", ");
      if (!dev.empty) {
        dev.docs.forEach(item => {
          let exists = data.developments.includes(
            String(item.data().externalId)
          );
          if (exists) {
            developments[`${item.id}`] = true;
          }
        });
      }
    }

    //Blocks
    const blo = await admin
      .firestore()
      .collection("blocks")
      .where("company.id", "==", company.id)
      .get();
    var blocks = [];
    if (data.blocks != null) {
      data.blocks = data.blocks.split(", ");
      if (!blo.empty) {
        blo.docs.forEach(item => {
          let exists = data.blocks.includes(String(item.data().externalId));
          if (exists) {
            blocks[`${item.id}`] = true;
          }
        });
      }
    }

    //Units
    const uni = await admin
      .firestore()
      .collection("units")
      .where("company.id", "==", company.id)
      .get();
    var units = [];
    if (data.units != null) {
      data.units = data.units.split(", ");
      if (!uni.empty) {
        uni.docs.forEach(item => {
          let exists = data.units.includes(String(item.data().externalId));
          if (exists) {
            units[`${item.id}`] = true;
          }
        });
      }
    }

    return await docRef.set({
      company: { id: company.id, name: company.data().name },
      ...data,
      validityDate: {
        start: new Date(data.validityDate.start),
        end: new Date(data.validityDate.end)
      },
      developments: { ...developments },
      blocks: { ...blocks },
      units: { ...units }
    });
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
