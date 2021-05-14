import { HttpsError } from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function deleteBuyer(externalId: string, companyId: string) {
  const db = admin.firestore();

  const company = await db
    .collection("companies")
    .doc(companyId)
    .get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }

  try {
    db.collection("buyers")
      .where("company.id", "==", company.id)
      .where("externalId", "==", externalId)
      .get()
      .then(function (querySnapshot) {
        querySnapshot.forEach(function (doc) {
          doc.ref.delete();
        });
      });
  } catch (e) {
    /* istanbul ignore next */
    console.log("company: " + company.id);
    /* istanbul ignore next */
    console.log(e);
  }
}
