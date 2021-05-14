import {
  CallableContext,
  HttpsError,
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function deleteDevelopmentFunction(
  externalId,
  context: CallableContext
) {
  const db = admin.firestore();
  const company = await db.collection("companies").doc(context.auth.uid).get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }
  try {
    const developments = await db
      .collection("developments")
      .where("company.id", "==", company.id)
      .where("externalId", "==", externalId)
      .get()
      .then(function (querySnapshot) {
        querySnapshot.forEach(function (development) {
          development.ref.delete();
        });
      });
    const developmentUnit = await db
      .collection("development-units")
      .where("company.id", "==", company.id)
      .where("development.externalId", "==", externalId)
      .get();
    developmentUnit.forEach(function (devUnit) {
      devUnit.ref.delete();
    });
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
