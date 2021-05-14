import {
  CallableContext,
  HttpsError,
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";
import * as _ from "lodash";

export async function mountDevelopmentUnitsFunction(
  data: any,
  context: CallableContext
) {
  const db = admin.firestore();
  const company = await db.collection("companies").doc(context.auth.uid).get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }
  try {
    if (!data) {
      console.log("mountDevelopmentUnitsFunction data:", data);
      return null;
    }

    const developmentUnit = await db
      .collection("development-units")
      .where("company.id", "==", company.id)
      .where("development.externalId", "==", data.externalId)
      .get();

    let docRef: FirebaseFirestore.DocumentReference;
    if (developmentUnit.empty) {
      docRef = await db.collection("development-units").doc();
    } else {
      docRef = developmentUnit.docs[0].ref;
    }

    const blocks = await db
      .collection("blocks")
      .where("company.id", "==", company.id)
      .where("development.externalId", "==", data.externalId)
      .get();

    const units = await db
      .collection("units")
      .where("company.id", "==", company.id)
      .where("development.externalId", "==", data.externalId)
      .get();

    let blockUnits: any = {};
    for (const unit of units.docs) {
      const externalId = unit.data().block.externalId;

      if (!blockUnits[externalId]) {
        blockUnits[externalId] = [];
      }
      blockUnits[externalId].push({
        area: unit.data().area,
        blueprint: unit.data().blueprint,
        floor: unit.data().floor,
        room: unit.data().room,
        externalId: unit.data().externalId,
        name: unit.data().name,
        id: unit.id,
        price: unit.data().price,
        prices:
          typeof unit.data().prices == "undefined" ? null : unit.data().prices,
        reservedBy:
          typeof unit.data().reservedBy == "undefined"
            ? null
            : unit.data().reservedBy,
        status: unit.data().status,
        typology: unit.data().typology,
      });
    }

    const blockList = blocks.docs.map((block) => {
      return {
        id: block.id,
        externalId: block.data().externalId,
        name: block.data().name,
        active: block.data().active,
        units: _.sortBy(blockUnits[block.data().externalId] || [], "floor"),
      };
    });

    await Promise.all(blockList);

    const mirror = {
      company: { id: company.id, name: company.data().name },
      development: { ...data },
      blocks: _.sortBy(blockList, "name"),
    };
    return await docRef.set(mirror);
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}
