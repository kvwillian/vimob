import {
  CallableContext,
  HttpsError
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function modifyActiveDevelopmentFunction(
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
    if (data.externalId === 0 && data.active === false) {
      await admin
        .firestore()
        .collection("developments")
        .where("company.id", "==", company.id)
        .get()
        .then(function(docs) {
          docs.forEach(function(docItem) {
            admin
              .firestore()
              .collection("developments")
              .doc(docItem.id)
              .update({
                active: data.active
              });
          });
        });
    } else {
      await admin
        .firestore()
        .collection("developments")
        .where("company.id", "==", company.id)
        .where("externalId", "==", data.externalId)
        .get()
        .then(function(docs) {
          docs.forEach(function(docItem) {
            admin
              .firestore()
              .collection("developments")
              .doc(docItem.id)
              .update({
                active: data.active
              });
          });
        });
    }
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
