import {
  CallableContext,
  HttpsError,
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function modifyStatusProposalFunction(
  data,
  context: CallableContext
) {
  //console.log('context :', context);
  //console.log('data :', data);

  const db = admin.firestore();
  const company = await db.collection("companies").doc(context.auth.uid).get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }
  try {
    const cp = await db
      .collection("company-statuses")
      .where("company.id", "==", company.id)
      .get();
    let companyStatuses = cp.docs[0].data();

    let proposal = await db
      .collection("proposals")
      .where("company.id", "==", company.id)
      .where("idProposalMega", "==", data.externalId)
      .get();

    let proposalToUpdate = {
      ...proposal.docs[0].data(),
      status: data.status,
      fromApp: false,
    };

    const docRef = await db
      .collection("proposals-logs")
      .doc(proposal.docs[0].id)
      .collection("proposalsLogsList")
      .doc();

    companyStatuses.proposals[`${data.status}`].text;

    await docRef.set({
      analyst: data.analyst,
      date: new Date(),
      description: {
        en_US: companyStatuses.proposals[`${data.status}`].text["en-US"],
        pt_BR: companyStatuses.proposals[`${data.status}`].text["pt-BR"],
      },
      status: {
        color: "#00D87A",
        type: data.status,
      },
    });

    return await proposal.docs[0].ref.update({
      ...proposalToUpdate,
    });
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
