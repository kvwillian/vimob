import {
  CallableContext,
  HttpsError
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

// externalId, userId, active
export async function addUserDevelopmentFunction(
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
    const development = await db
      .collection("developments")
      .where("company.id", "==", company.id)
      .where("externalId", "==", parseInt(data.development.externalId))
      .get();

    let developmentUsers = {};
    let docRef: FirebaseFirestore.DocumentReference;
    if (development.empty) {
      docRef = db.collection("developments").doc();
    } else {
      docRef = development.docs[0].ref;
      developmentUsers = development.docs[0].data().users || null;
    }

    return await docRef.update({
      users: {
        ...developmentUsers,
        ...data.users
      }
    });
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
