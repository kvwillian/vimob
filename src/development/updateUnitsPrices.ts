import {
  CallableContext,
  HttpsError
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";
import UpdateUnitsPrices from "../models/updateUnitsPrices";

export async function updateUnitsPricesFunction(
  data: UpdateUnitsPrices,
  context: CallableContext
) {
  const firebaseLUWSize = 500;

  const db = admin.firestore();
  const company = await db
    .collection("companies")
    .doc(context.auth.uid)
    .get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }
  try {
    const units = await db
      .collection("units")
      .where("company.id", "==", company.id)
      .where("development.externalId", "==", data.developmentExternalId)
      .get();

    let writeBatch = db.batch();
    let totalOperations: number = 0;

    for (const unitPrice in data.unitsPrices) {
      const existsUnit = units.docs.find(
        u => u.data().externalId == data.unitsPrices[unitPrice].externalId
      );
      if (existsUnit) {
        const _prices = JSON.parse(
          `${data.unitsPrices[unitPrice].effectiveDate}`
        );

        const unitToSave = {
          prices: _prices,
          price: data.unitsPrices[unitPrice].price
        };

        const currentBatchSize = totalOperations + _prices.length + 1

        if (currentBatchSize <= firebaseLUWSize) {
          writeBatch.update(existsUnit.ref, unitToSave);
          totalOperations = currentBatchSize;
        } else {
          const old = writeBatch;
          writeBatch = db.batch();
          await old.commit();
          totalOperations = 0;
        }
      }
    }

    writeBatch.commit();

    return true;
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
