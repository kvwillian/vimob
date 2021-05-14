import {
  CallableContext,
  HttpsError
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function deleteProposalFunction(
  externalId,
  context: CallableContext
) {
  const db = admin.firestore();
  const storageAttachments = admin.storage();
  var docProposalId;
  const company = await db.collection("companies").doc(context.auth.uid).get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }

  try {
    const proposals = await db
      .collection("proposals")
      .where("company.id", "==", company.id)
      .where("idProposalMega", "==", externalId)
      .get();
    proposals.forEach(function (proposal) {
      docProposalId = proposal.id;
      proposal.ref.delete();
    });

    db.collection("attachments")
      .doc(`${docProposalId}`)
      .collection("attachmentsList")
      .get()
      .then(function (querysnapshot) {
        querysnapshot.forEach(function (doc) {
          doc.ref.delete();
        });
      });

    await db.collection("attachments").doc(`${docProposalId}`).delete();
    const bucket = storageAttachments.bucket("mega-portaldevendas.appspot.com");
    const options = {
      prefix: `proposalsAttachments/${docProposalId}/`
    };
    await bucket.getFiles(options).then(results => {
      const files = results[0];
      files.forEach(file => {
        file.delete();
      });
    });
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
  }
}
