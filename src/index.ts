import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { modifyStatusUnitFunction } from "./development/modifyStatusUnit";
import { modifyStatusProposalFunction } from "./proposal/modifyStatusProposal";
import { getProposalFunction } from "./proposal/getProposal";
import { deleteProposalFunction } from "./proposal/deleteProposal";
import { deleteBuyerFunction } from "./buyer/deleteBuyerFunction";
import { AddCompanyToken } from "./security/AddCompanyToken";
import { addCompanyStatusesFunction } from "./company-status/addCompanyStatuses";
import { addDevelopmentFunction } from "./development/addDevelopment";
import { addUnitsFunction } from "./development/addUnits";
import { updateUnitsPricesFunction } from "./development/updateUnitsPrices";
import { mountDevelopmentUnitsFunction } from "./development/mountDevelopmentUnits";
import { addPaymentPlanFunction } from "./payment-plans/addPaymentPlan";
import { addUserDevelopmentFunction } from "./user/addUserDevelopment";
import { addBuyerFunction } from "./buyer/addBuyerFunction";
import { modifyActiveDevelopmentFunction } from "./development/modifyActiveDevelopment";
import { deletePaymentPlanFunction } from "./payment-plans/deletePaymentPlan";
import { deleteUnitFunction } from "./development/deleteUnit";
import { deleteBlockFunction } from "./development/deleteBlock";
import { deleteDevelopmentFunction } from "./development/deleteDevelopment";
import { setCompanyUrlFunction } from "./company/setCompanyUrl";
import { addUserPermissionFunction } from "./user/addUserPermission";

admin.initializeApp(functions.config());
admin.firestore().settings({ timestampsInSnapshots: true });

export const modifyActiveDevelopment = functions.https.onCall(
  modifyActiveDevelopmentFunction
);
export const modifyStatusUnit = functions.https.onCall(
  modifyStatusUnitFunction
);
export const modifyStatusProposal = functions.https.onCall(
  modifyStatusProposalFunction
);
export const getProposal = functions.https.onCall(getProposalFunction);
export const deleteProposal = functions.https.onCall(deleteProposalFunction);
export { replaceNameBuyer } from "./proposal/replaceNameBuyer";
export {
  sendStatusChangedNotification,
  releaseDevelopmentNotification,
} from "./notifications/notification";
export { AddCompanyToken } from "./security/AddCompanyToken";
export { copyInviteToInvitations } from "./user/copyInviteToInvitations";
export * from "./security/generate-qr-code";

export const addCompanyStatuses = functions.https.onCall(
  addCompanyStatusesFunction
);
export const addDevelopment = functions.https.onCall(addDevelopmentFunction);
export const addUnits = functions.https.onCall(addUnitsFunction);
export const updateUnitsPrices = functions.https.onCall(
  updateUnitsPricesFunction
);
export const mountDevelopmentUnits = functions.https.onCall(
  mountDevelopmentUnitsFunction
);
export const addPaymentPlan = functions.https.onCall(addPaymentPlanFunction);
export const addUserDevelopment = functions.https.onCall(
  addUserDevelopmentFunction
);
export const addBuyer = functions.https.onCall(addBuyerFunction);
export const deleteBuyer = functions.https.onCall(deleteBuyerFunction);
export const deletePaymentPlan = functions.https.onCall(
  deletePaymentPlanFunction
);
export const deleteUnit = functions.https.onCall(deleteUnitFunction);
export const deleteBlock = functions.https.onCall(deleteBlockFunction);
export const deleteDevelopment = functions.https.onCall(
  deleteDevelopmentFunction
);
export const setCompanyUrl = functions.https.onCall(setCompanyUrlFunction);
export const addUserPermission = functions.https.onCall(
  addUserPermissionFunction
);
