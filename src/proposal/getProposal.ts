import {
  CallableContext,
  HttpsError
} from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";

export async function getProposalFunction(data: any, context: CallableContext) {
  const db = admin.firestore();
  const company = await db
    .collection("companies")
    .doc(context.auth.uid)
    .get();

  if (!company.exists) {
    throw new HttpsError("invalid-argument", "Unauthenticated user");
  }
  try {
    const proposal = await db
      .collection("proposals")
      .doc(data.id)
      .get();
    const buyer = await db
      .collection("buyers")
      .doc(proposal.data().buyer.id)
      .get();
    const unit = await db
      .collection("units")
      .doc(proposal.data().unit.id)
      .get();
    const payment = await db
      .collection("payment-plans")
      .doc(proposal.data().paymentPlan.docId)
      .get();
    const user = await db
      .collection("users")
      .doc(proposal.data().agent.id)
      .get();
    const totalValue = await getPaymentPlanTotalPrice(
      proposal.data().modifiedPaymentPlan.series
    );
    const firstDownPaymentDate = await getFirstDownPaymentDate(
      proposal.data().modifiedPaymentPlan.series
    );
    const lastDownPayment = await getLastDownPayment(
      proposal.data().modifiedPaymentPlan.series
    );

    return {
      idProposalMega: proposal.data().idProposalMega,
      developmentExternalId: unit.data().development.externalId,
      blockExternalId: unit.data().block.externalId,
      unitExternalId: unit.data().externalId,
      buyerExternalId: buyer.data().externalId,
      paymentExternalId: payment.data().externalId,
      emolument: payment.data().emolument,
      classification: payment.data().classification,
      userExternalId: user.data().companies[`${company.id}`].externalId,
      proposalDate: proposal.data().date,
      totalValue: totalValue,
      firstDownPaymentDate: firstDownPaymentDate,
      lastDownPaymentDate: lastDownPayment[0],
      lastDownPaymentQuantity: lastDownPayment[1],
      series: proposal.data().modifiedPaymentPlan.series
    };
  } catch (e) {
    console.log("company: " + company.id);
    console.log(e);
    return null;
  }
}

async function getPaymentPlanTotalPrice(series) {
  if (!series) {
    throw new Error(
      "There are no series defined to calculate total price by payment plan"
    );
  }

  return series.reduce((prev, next) => {
    return prev + next.prices.nominal.seriesTotal;
  }, 0);
}

async function getFirstDownPaymentDate(series) {
  if (!series) return null;

  const resp = series.filter(serie => {
    return serie.serieTypeId === 1 || serie.serieTypeId === 19;
  });
  let d = null;

  for (const serie of resp) {
    if (d === null || serie.dueDate.date._seconds < d)
      d = serie.dueDate.date._seconds;
  }

  return d;
}

async function getLastDownPayment(series) {
  if (!series) return null;

  const resp = series.filter(serie => {
    return serie.serieTypeId === 1 || serie.serieTypeId === 19;
  });

  let dtMax = null;
  let dtAux = null;
  let payments = 0;
  let d = null;

  for (const serie of resp) {
    dtAux = serie.dueDate.date.toDate();
    dtAux = new Date(dtAux.getFullYear(), dtAux.getMonth(), dtAux.getDate());
    dtAux.setMonth(dtAux.getMonth() + serie.numberOfPayments);

    if (dtMax === null || dtMax < dtAux) {
      d = serie.dueDate.date._seconds;
      dtMax = new Date(dtAux.getFullYear(), dtAux.getMonth(), dtAux.getDate());
      payments = serie.numberOfPayments;
    }
  }

  return [d, payments];
}
