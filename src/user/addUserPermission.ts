import {
  CallableContext,
  HttpsError,
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function addUserPermissionFunction(
  data: any,
  context: CallableContext
) {
  const db = admin.firestore();
  const company = await db.collection("companies").doc(context.auth.uid).get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }

  try {
    const user = await db
      .collection("users")
      .doc(data.userPermission.userId)
      .get();

    const userPermission = await db
      .collection("user-permissions")
      .where("company.id", "==", company.id)
      .where("user.externalId", "==", data.userPermission.userExternalId)
      .get();

    let docRef: FirebaseFirestore.DocumentReference;

    if (userPermission.empty) {
      docRef = db.collection("user-permissions").doc();
    } else {
      docRef = userPermission.docs[0].ref;
    }

    await docRef.set({
      company: { id: company.id, name: company.data().name },
      user: {
        externalId: user.data().companies[`${company.id}`].externalId,
        name: user.data().companies[`${company.id}`].name,
      },
      reserveEnabled: data.userPermission.reserveEnabled,
    });

    var docRefUsers = user.ref;

    var userCompany = user.data().companies[`${company.id}`];

    userCompany = {
      ...userCompany,
      permissionId: docRef.id,
    };

    await docRefUsers.update({
      companies: {
        ...user.data().companies,
        [`${company.id}`]: userCompany,
      },
    });
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
