import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const AddCompanyToken = functions.firestore
  .document("users/{id}")
  .onWrite(async (change, context) => {
    const data = change.after.data().companies;
    console.log("ID:", change.after.id);

    const additionalClaims = {
      companies: [],
    };

    if (data !== undefined) {
      const tokens = Object.keys(data).map((company) => {
        if (data[company].status) {
          return company;
        } else {
          return null;
        }
      });
      additionalClaims.companies = tokens;
      admin.auth().setCustomUserClaims(context.params.id, additionalClaims);
      console.log(
        "context.params.id: ",
        context.params.id,
        " additionalClaims: ",
        additionalClaims
      );
    } else {
      admin.auth().setCustomUserClaims(context.params.id, additionalClaims);
    }
  });
