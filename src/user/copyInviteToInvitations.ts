import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const copyInviteToInvitations = functions.firestore
  .document("invitations/{id}/{invites}/{idInvite}")
  .onWrite(async (change, context) => {
    let dataInvitation: any;
    const snapshot = change.after;
    const inviteChange = snapshot.data();
    const invitation = await admin
      .firestore()
      .collection("invitations")
      .doc(context.params.id)
      .get();

    if (!invitation.exists) {
      let vId = context.params.idInvite;
      dataInvitation = {
        vId: {
          amount: 0,
          used: 0,
          userId: 0
        }
      };
    } else {
      dataInvitation = invitation.data();
    }
    let addOrUpdateInvite = {
      ...dataInvitation.documents
    };

    addOrUpdateInvite[context.params.idInvite] = {
      amount: inviteChange.amount,
      used: inviteChange.used,
      userId: inviteChange.userId
    };

    await admin
      .firestore()
      .collection("invitations")
      .doc(context.params.id)
      .set({
        documents: addOrUpdateInvite
      });
  });
