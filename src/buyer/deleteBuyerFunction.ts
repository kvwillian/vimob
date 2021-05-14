import { CallableContext } from "firebase-functions/lib/providers/https";
import { deleteBuyer } from "./deleteBuyer";

export async function deleteBuyerFunction(
  externalId,
  context: CallableContext
) {
  await deleteBuyer(externalId, context.auth.uid);
}
