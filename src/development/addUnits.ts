import {
  CallableContext,
  HttpsError
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";
import { promises } from "fs";

export async function addUnitsFunction(data: any, context: CallableContext) {
  const db = admin.firestore();
  const company = await db
    .collection("companies")
    .doc(context.auth.uid)
    .get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }
  try {
    const firebaseLUWSize = 500;
    let totalOperations: number = 0;

    let writeBatch = db.batch();
    let deleteBatch = db.batch();

    const block = await db
      .collection("blocks")
      .where("company.id", "==", company.id)
      .where("development.externalId", "==", data.development.externalId)
      .where("externalId", "==", data.block.externalId)
      .get();

    const units = await db
      .collection("units")
      .where("company.id", "==", company.id)
      .where("development.externalId", "==", data.development.externalId)
      .where("block.externalId", "==", data.block.externalId)
      .get();

    let docRef: FirebaseFirestore.DocumentReference;
    if (block.empty) {
      docRef = db.collection("blocks").doc();
    } else {
      docRef = block.docs[0].ref;
    }

    await docRef.set({
      company: { id: company.id, name: company.data().name },
      development: { ...data.development },
      ...data.block,
      deliveryDate: data.block.deliveryDate
        ? new Date(data.block.deliveryDate)
        : null
    });

    let promise: Promise<any>[];
    let maxPrice: number = Number.NEGATIVE_INFINITY;
    let minPrice: number = Number.POSITIVE_INFINITY;
    let maxArea: number = Number.NEGATIVE_INFINITY;
    let minArea: number = Number.POSITIVE_INFINITY;
    let maxRooms: number = Number.NEGATIVE_INFINITY;
    let minRooms: number = Number.POSITIVE_INFINITY;

    // Exclusao de unidades
    units.docs.forEach((unitDoc) => {
      var undExiste;
      (data.units as any[]).map((unitOracle) => {
        if (unitDoc.data().externalId == unitOracle.externalId)
          undExiste = unitDoc.data().externalId;
      });
      if (!undExiste) {
        deleteBatch.delete(db.collection("units").doc(unitDoc.id));
      }
    });

    promise = (data.units as any[]).map(async (unit) => {
      //Get range of unit
      if (data.block.active) {
        maxArea = getHighestValue(unit.area.privateSquareMeters, maxArea);
        minArea = getFewerValue(unit.area.privateSquareMeters, minArea);

        maxPrice = getHighestValue(unit.price, maxPrice);
        minPrice = getFewerValue(unit.price, minPrice);

        maxRooms = getHighestValue(unit.room, maxRooms);
        minRooms = getFewerValue(unit.room, minRooms);
      }

      const existsUnit = units.docs.find(
        (u) => u.data().externalId == unit.externalId
      );
      const unitToSave = {
        company: { id: company.id, name: company.data().name },
        development: { ...data.development },
        block: {
          id: docRef.id,
          ...data.block,
          deliveryDate: data.block.deliveryDate
            ? new Date(data.block.deliveryDate)
            : null
        },
        ...unit
      };

      if (existsUnit) {
        if (totalOperations <= firebaseLUWSize) {
          writeBatch.update(existsUnit.ref, unitToSave);
          totalOperations++;
        } else {
          const old = writeBatch;
          writeBatch = db.batch();
          await old.commit();
          totalOperations = 0;
        }
      } else {
        if (totalOperations <= firebaseLUWSize) {
          writeBatch.create(db.collection("units").doc(), unitToSave);
          totalOperations++;
        } else {
          const old = writeBatch;
          writeBatch = db.batch();
          await old.commit();
          totalOperations = 0;
        }
      }
    });

    promise.push(deleteBatch.commit());
    promise.push(writeBatch.commit());

    if (data.block.active) {
      await updateUnitOverview(
        maxArea,
        minArea,
        maxPrice,
        minPrice,
        maxRooms,
        minRooms
      );
    }

    return await Promise.all(promise);
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }

  async function updateUnitOverview(
    maxArea: number,
    minArea: number,
    maxPrice: number,
    minPrice: number,
    maxRooms: number,
    minRooms: number
  ) {
    const developmentDoc = await db
      .collection("developments")
      .doc(data.development.id)
      .get();
    if (developmentDoc.data().unitOverview) {
      await db
        .collection("developments")
        .doc(data.development.id)
        .update({
          unitOverview: {
            maxArea:
              developmentDoc.data().unitOverview.maxArea > maxArea
                ? developmentDoc.data().unitOverview.maxArea
                : maxArea,
            minArea:
              developmentDoc.data().unitOverview.minArea < minArea
                ? developmentDoc.data().unitOverview.minArea
                : minArea,
            maxPrice:
              developmentDoc.data().unitOverview.maxPrice > maxPrice
                ? developmentDoc.data().unitOverview.maxPrice
                : maxPrice,
            minPrice:
              developmentDoc.data().unitOverview.minPrice < minPrice
                ? developmentDoc.data().unitOverview.minPrice
                : minPrice,
            maxRooms:
              developmentDoc.data().unitOverview.maxRooms > maxRooms
                ? developmentDoc.data().unitOverview.maxRooms
                : maxRooms,
            minRooms:
              developmentDoc.data().unitOverview.minRooms < minRooms
                ? developmentDoc.data().unitOverview.minRooms
                : minRooms
          }
        });
    } else {
      await db
        .collection("developments")
        .doc(data.development.id)
        .update({
          unitOverview: {
            maxArea: maxArea !== Number.NEGATIVE_INFINITY ? maxArea : 0,
            minArea: minArea !== Number.POSITIVE_INFINITY ? minArea : 0,
            maxPrice: maxPrice !== Number.NEGATIVE_INFINITY ? maxPrice : 0,
            minPrice: minPrice !== Number.POSITIVE_INFINITY ? minPrice : 0,
            maxRooms: maxRooms !== Number.NEGATIVE_INFINITY ? maxRooms : 0,
            minRooms: minRooms !== Number.POSITIVE_INFINITY ? minRooms : 0
          }
        });
    }
  }
}

function getHighestValue(value: number, highest: number): number {
  if (value !== null && value > highest) {
    return value;
  } else {
    return highest;
  }
}

function getFewerValue(value: number, fewer: number): number {
  if (value !== null && value < fewer) {
    return value;
  } else {
    return fewer;
  }
}
