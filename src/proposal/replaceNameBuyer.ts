import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const replaceNameBuyer = functions.firestore
  .document("buyers/{id}")
  .onUpdate(async (change, context) => {
    if (change.after.data().name !== change.before.data().name) {
      await admin.firestore().runTransaction(async transaction => {
        const proposals = await admin
          .firestore()
          .collection("proposals")
          .where("buyer.id", "==", context.params.id)
          .get();

        if (!proposals.empty) {
          proposals.forEach(proposal => {
            const docRef = admin
              .firestore()
              .collection("proposals")
              .doc(proposal.id);
            transaction.update(docRef, {
              buyer: { id: context.params.id, name: change.after.data().name }
            });
          });
        }
      });
    }
  });
