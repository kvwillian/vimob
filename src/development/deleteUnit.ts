import {
  CallableContext,
  HttpsError,
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function deleteUnitFunction(externalId, context: CallableContext) {
  const db = admin.firestore();
  const company = await db.collection("companies").doc(context.auth.uid).get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }
  try {
    var developmentExternalId;
    const units = await db
      .collection("units")
      .where("company.id", "==", company.id)
      .where("externalId", "==", externalId)
      .get();

    units.forEach(function (unit) {
      developmentExternalId = unit.data().development.externalId;
      unit.ref.delete();
      });
    return developmentExternalId;
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
