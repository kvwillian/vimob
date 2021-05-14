import {
  CallableContext,
  HttpsError
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function deletePaymentPlanFunction(
  externalId,
  context: CallableContext
) {
  const db = admin.firestore();
  const company = await db.collection("companies").doc(context.auth.uid).get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }

  try {
    db.collection("payment-plans")
      .where("company.id", "==", company.id)
      .where("externalId", "==", externalId)
      .get()
      .then(function(querySnapshot) {
        querySnapshot.forEach(function(doc) {
          doc.ref.delete();
        });
      });
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
  }
}
