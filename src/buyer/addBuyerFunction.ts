import { CallableContext } from "firebase-functions/lib/providers/https";

import { addBuyer } from "./addBuyer";

export async function addBuyerFunction(data: any, context: CallableContext) {
  return addBuyer(data, context.auth.uid);
}
