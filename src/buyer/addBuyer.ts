import { HttpsError } from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function addBuyer(data: any, companyId: string) {
  const db = admin.firestore();
  const company = await db
    .collection("companies")
    .doc(companyId)
    .get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }

  try {
    const buyer = await db
      .collection("buyers")
      .where("company.id", "==", company.id)
      .where("externalId", "==", data.externalId)
      .get();

    let docRef: FirebaseFirestore.DocumentReference = null;
    let vUsers = "";

    if (buyer.empty) {
      docRef = db.collection("buyers").doc();
    } else {
      vUsers = buyer.docs[0].data().user;
      docRef = buyer.docs[0].ref;
    }
    return await docRef.set({
      company: { id: company.id, name: company.data().name },
      ...data,
      user: data.user
    });
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
