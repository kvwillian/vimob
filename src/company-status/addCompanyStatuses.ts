import {
  CallableContext,
  HttpsError
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function addCompanyStatusesFunction(
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
    const companyStatuses = await db
      .collection("company-statuses")
      .where("company.id", "==", company.id)
      .get();

    let docRef: FirebaseFirestore.DocumentReference;
    if (companyStatuses.empty) {
      docRef = db.collection("company-statuses").doc();
    } else {
      docRef = companyStatuses.docs[0].ref;
    }

    return await docRef.set({
      company: { id: company.id, name: company.data().name },
      proposals: data.proposals,
      units: data.units
    });
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
