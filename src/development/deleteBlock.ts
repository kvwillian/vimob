import {
  CallableContext,
  HttpsError,
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function deleteBlockFunction(
  externalId,
  context: CallableContext
) {
  const db = admin.firestore();
  const company = await db.collection("companies").doc(context.auth.uid).get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }
  try {
    var developmentExternalId;
    const blocks = await db
      .collection("blocks")
      .where("company.id", "==", company.id)
      .where("externalId", "==", externalId)
      .get();
    blocks.forEach(function (block) {
      developmentExternalId = block.data().development.externalId;
      block.ref.delete();
      });
    return developmentExternalId;
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
