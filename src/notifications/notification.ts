import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const sendStatusChangedNotification = functions.firestore
  .document("proposals/{id}")
  .onUpdate(async (change, context) => {
    const after = change.after.data();
    const before = change.before.data();

    if (before.status === after.status || after.fromApp) {
      console.log("no notification");
      return null;
    }

    let payload;
    if (after.status === "approved") {
      payload = {
        notification: {
          title: `Status da proposta atualizado`,
          body: `Parabéns! A proposta ${
            after.idProposalMega ?? ""
          } foi aprovada`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          status: "done",
          proposalId: after.idProposalMega.toString(),
        },
      };
    } else {
      const companyStatusesDoc = await admin
        .firestore()
        .collection("company-statuses")
        .where("company.id", "==", after.company.id)
        .get();
      var status = "";
      if (!companyStatusesDoc.empty) {
        const companyStatuses = companyStatusesDoc.docs[0].data();
        status = companyStatuses.proposals[after.status].text["pt-BR"];
      }

      payload = {
        notification: {
          title: `Status da proposta atualizado`,
          body: `A proposta ${
            after.idProposalMega ?? ""
          } foi alterada para ${status}`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          status: "done",
          proposalId: after.idProposalMega.toString(),
        },
      };
    }

    for (let uid in before.users) {
      let fcmToken = await getFcmToken(uid);

      if (fcmToken) {
        try {
          await admin.messaging().sendToDevice(fcmToken, payload);
          console.log(
            `Success - idProposalMega: ${
              after.idProposalMega ?? ""
            } -> change status to -> ${status}`
          );
        } catch (error) {
          console.log(
            `Error - idProposalMega: ${after.idProposalMega ?? ""}`,
            error
          );
        }
      } else {
        console.log(`user ${uid} `);
      }
    }
    return null;
  });

export const releaseDevelopmentNotification = functions.firestore
  .document("developments/{id}")
  .onCreate(async (snap, context) => {
    const uid = context.params.id;

    let payload = {
      notification: {
        title: "Empreendimento liberado",
        body: "Novos empreendimentos foram liberados",
      },
    };

    let fcmToken = await getFcmToken(uid);

    if (fcmToken) {
      try {
        const response = await admin
          .messaging()
          .sendToDevice(fcmToken, payload);
        console.log("Success", response);
      } catch (error) {
        console.log("Error", error);
      }
    } else {
      console.log(`user ${uid} `);
    }

    return null;
  });

async function getFcmToken(key): Promise<string> {
  let pushFcmToken;

  await admin
    .firestore()
    .collection("users")
    .doc(key)
    .get()
    .then((doc) => {
      let data = doc.data();
      pushFcmToken = data.fcmToken;
    })
    .catch((err) => console.log(err));

  return pushFcmToken;
}
