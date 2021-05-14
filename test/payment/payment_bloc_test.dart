import 'package:flutter_test/flutter_test.dart';
import 'package:vimob/blocs/payment/payment_bloc.dart';
import 'package:vimob/models/payment/payment.dart';

void main() {
  group("Payment bloc |", () {
    test("Should convert to daysToStart", () {
      DueTypes dueTypes = PaymentBloc().convertDueTypes("daysToStart");

      expect(dueTypes, DueTypes.daysToStart);
    });

    test("Should convert to startWithUpfront", () {
      DueTypes dueTypes = PaymentBloc().convertDueTypes("startWithUpfront");

      expect(dueTypes, DueTypes.startWithUpfront);
    });

    test("Should convert to startAfterUpfront", () {
      DueTypes dueTypes = PaymentBloc().convertDueTypes("startAfterUpfront");

      expect(dueTypes, DueTypes.startAfterUpfront);
    });
    test("Should convert to monthsAfterConstruction", () {
      DueTypes dueTypes =
          PaymentBloc().convertDueTypes("monthsAfterConstruction");

      expect(dueTypes, DueTypes.monthsAfterConstruction);
    });
    test("Should convert to monthsAfterProposal", () {
      DueTypes dueTypes = PaymentBloc().convertDueTypes("monthsAfterProposal");

      expect(dueTypes, DueTypes.monthsAfterProposal);
    });
    test("Should convert to null", () {
      DueTypes dueTypes = PaymentBloc().convertDueTypes(null);

      expect(dueTypes, null);
    });

    test("Should convert to TP", () {
      InterestTypes interestTypes = PaymentBloc().convertInterestTypes("TP");

      expect(interestTypes, InterestTypes.tp);
    });

    test("Should convert to SAC", () {
      InterestTypes interestTypes = PaymentBloc().convertInterestTypes("SAC");

      expect(interestTypes, InterestTypes.sac);
    });

    test("Should convert to SACOC", () {
      InterestTypes interestTypes = PaymentBloc().convertInterestTypes("SACOC");

      expect(interestTypes, InterestTypes.sacoc);
    });

    test("Should convert to null", () {
      InterestTypes interestTypes = PaymentBloc().convertInterestTypes(null);

      expect(interestTypes, null);
    });

    test("Should convert to adjustPrice", () {
      PostDeliveryTypes postDeliveryTypes =
          PaymentBloc().convertPostDeliveryTypes("adjustPrice");

      expect(postDeliveryTypes, PostDeliveryTypes.adjustPrice);
    });

    test("Should convert to delivery", () {
      PostDeliveryTypes postDeliveryTypes =
          PaymentBloc().convertPostDeliveryTypes("delivery");

      expect(postDeliveryTypes, PostDeliveryTypes.delivery);
    });

    test("Should convert to deliveryOrFinancing", () {
      PostDeliveryTypes postDeliveryTypes =
          PaymentBloc().convertPostDeliveryTypes("deliveryOrFinancing");

      expect(postDeliveryTypes, PostDeliveryTypes.deliveryOrFinancing);
    });

    test("Should convert to financing", () {
      PostDeliveryTypes postDeliveryTypes =
          PaymentBloc().convertPostDeliveryTypes("financing");

      expect(postDeliveryTypes, PostDeliveryTypes.financing);
    });

    test("Should convert to overcome", () {
      PostDeliveryTypes postDeliveryTypes =
          PaymentBloc().convertPostDeliveryTypes("overcome");

      expect(postDeliveryTypes, PostDeliveryTypes.overcome);
    });

    test("Should convert to null", () {
      PostDeliveryTypes postDeliveryTypes =
          PaymentBloc().convertPostDeliveryTypes(null);

      expect(postDeliveryTypes, null);
    });

    test("Should convert to act", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("act");

      expect(seriesTypes, SeriesTypes.act);
    });
    test("Should convert to bimonthly", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("bimonthly");

      expect(seriesTypes, SeriesTypes.bimonthly);
    });
    test("Should convert to delivery", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("delivery");

      expect(seriesTypes, SeriesTypes.delivery);
    });
    test("Should convert to eight-monthly", () {
      SeriesTypes seriesTypes =
          PaymentBloc().convertSeriesType("eight-monthly");

      expect(seriesTypes, SeriesTypes.eightMonthly);
    });
    test("Should convert to eleven-monthly", () {
      SeriesTypes seriesTypes =
          PaymentBloc().convertSeriesType("eleven-monthly");

      expect(seriesTypes, SeriesTypes.elevenMonthly);
    });
    test("Should convert to fgts", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("FGTS");

      expect(seriesTypes, SeriesTypes.fgts);
    });
    test("Should convert to financing", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("financing");

      expect(seriesTypes, SeriesTypes.financing);
    });
    test("Should convert to five-monthly", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("five-monthly");

      expect(seriesTypes, SeriesTypes.fiveMonthly);
    });
    test("Should convert to monthly", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("monthly");

      expect(seriesTypes, SeriesTypes.monthly);
    });
    test("Should convert to nine-monthly", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("nine-monthly");

      expect(seriesTypes, SeriesTypes.nineMonthly);
    });
    test("Should convert to periodically", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("periodically");

      expect(seriesTypes, SeriesTypes.periodically);
    });
    test("Should convert to quarterly", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("quarterly");

      expect(seriesTypes, SeriesTypes.quarterly);
    });
    test("Should convert to semester", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("semester");

      expect(seriesTypes, SeriesTypes.semester);
    });
    test("Should convert to seven-monthly", () {
      SeriesTypes seriesTypes =
          PaymentBloc().convertSeriesType("seven-monthly");

      expect(seriesTypes, SeriesTypes.sevenMonthly);
    });
    test("Should convert to subsidy", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("subsidy");

      expect(seriesTypes, SeriesTypes.subsidy);
    });
    test("Should convert to ten-monthly", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("ten-monthly");

      expect(seriesTypes, SeriesTypes.tenMonthly);
    });
    test("Should convert to trimester", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("trimester");

      expect(seriesTypes, SeriesTypes.trimester);
    });
    test("Should convert to unic", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("unic");

      expect(seriesTypes, SeriesTypes.unic);
    });
    test("Should convert to upfront", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("upfront");

      expect(seriesTypes, SeriesTypes.upfront);
    });
    test("Should convert to without", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("without");

      expect(seriesTypes, SeriesTypes.without);
    });
    test("Should convert to yearly", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType("yearly");

      expect(seriesTypes, SeriesTypes.yearly);
    });
    test("Should convert to null", () {
      SeriesTypes seriesTypes = PaymentBloc().convertSeriesType(null);

      expect(seriesTypes, null);
    });
  });
}
