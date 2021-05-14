import { CallableContext } from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function setCompanyUrlFunction(
  newUrl: string,
  context: CallableContext
) {
  const db = admin.firestore();

  try {
    await db
      .collection("companies")
      .doc(context.auth.uid)
      .update({ url: newUrl });
  } catch (e) {
    console.log("company: " + context.auth.uid);
    console.log(e);
  }
}
