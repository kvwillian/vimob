import {
  CallableContext,
  HttpsError,
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";
import DevelopmentReference from "../models/DevelopmentReference";

export async function addDevelopmentFunction(
  data: any,
  context: CallableContext
) {
  const db = admin.firestore();
  const company = await db.collection("companies").doc(context.auth.uid).get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }
  try {
    const development = await db
      .collection("developments")
      .where("company.id", "==", company.id)
      .where("externalId", "==", data.externalId)
      .get();

    let developmentUsers = {};
    let docRef: FirebaseFirestore.DocumentReference;
    if (development.empty) {
      docRef = db.collection("developments").doc();
      await docRef.set({
        company: { id: company.id, name: company.data().name },
        ...data,
        users: developmentUsers,
      });
    } else {
      docRef = development.docs[0].ref;
      developmentUsers = development.docs[0].data().users || null;
      await docRef.update({
        company: { id: company.id, name: company.data().name },
        ...data,
        users: developmentUsers,
      });
    }

    return new DevelopmentReference(
      docRef.id,
      data.name,
      data.externalId,
      data.type
    );
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
