import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vimob/i18n/test_i18n_delegate.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/development/unit.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/proposal/proposal_detail_information_tab.dart';

void main() {
  Widget _createWidget({Development development, Proposal proposal}) {
    return LayoutBuilder(builder: (context, constraints) {
      Style().responsiveInit(constraints: constraints);
      return MaterialApp(
        localizationsDelegates: [
          TestI18nDelegate(),
        ],
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('pt', 'BR'),
        ],
        home: Material(
          child: ProposalDetailInformationTab(
            development: development,
            proposal: proposal,
          ),
        ),
      );
    });
  }

  // final TestWidgetsFlutterBinding binding =
  //     TestWidgetsFlutterBinding.ensureInitialized();

  // binding.window.physicalSizeTestValue = Size(1, 20000);
  // binding.window.devicePixelRatioTestValue = 1.0;

  group("Proposal detail information tab | ", () {
    var developmentNameText =
        find.byKey(Key("proposal_detail_information_development_name"));
    var addressText = find.byKey(Key("proposal_detail_information_address"));
    var typeText = find.byKey(Key("proposal_detail_information_type_text"));
    var typologyText =
        find.byKey(Key("proposal_detail_information_typology_text"));
    var metricText = find.byKey(Key("proposal_detail_information_metric_text"));
    var roomsText = find.byKey(Key("proposal_detail_information_rooms_text"));
    var paymentPlanNameText =
        find.byKey(Key("proposal_detail_information_payment_plan_name_text"));
    var serieUpfrontText =
        find.byKey(Key("proposal_detail_information_upfront_text"));
    var serieMonthlyText =
        find.byKey(Key("proposal_detail_information_monthly_text"));

    testWidgets("Should show all information", (WidgetTester tester) async {
      await tester.pumpWidget(
        _createWidget(
          development: Development()
            ..name = "Development name"
            ..type = "land"
            ..address = (Address()
              ..streetAddress = "Street"
              ..number = "10"
              ..neighborhood = "neighborhood"
              ..city = "city"
              ..state = "state"
              ..zipCode = "00000-000"),
          proposal: Proposal()
            ..development = (DevelopmentReference()..name = "Development name")
            ..unit = (ProposalUnit()
              ..name = "Unit name"
              ..developmentUnit = (Unit()
                ..room = 2
                ..typology = "typology"
                ..type = "land"
                ..area = (UnitArea()..privateSquareMeters = 100)
                ..block = (Reference()..name = "blockName")))
            ..modifiedPaymentPlan = null
            ..paymentPlan = (PaymentPlan()
              ..name = "Payment Plan"
              ..series = <PaymentSeries>[
                PaymentSeries()
                  ..type = SeriesTypes.upfront
                  ..numberOfPayments = 10
                  ..prices = (PaymentSeriesPrices()
                    ..nominal = (SeriesPrices()
                      ..seriesValue = 1000
                      ..seriesTotal = 10000)),
                PaymentSeries()
                  ..type = SeriesTypes.monthly
                  ..numberOfPayments = 5
                  ..prices = (PaymentSeriesPrices()
                    ..nominal = (SeriesPrices()
                      ..seriesValue = 1000
                      ..seriesTotal = 5000)),
              ]),
        ),
      );

      expect(tester.widget<Text>(developmentNameText).data, "Development name");
      expect(tester.widget<Text>(addressText).data,
          "Street, 10 - neighborhood - city - state - 00000-000");

      expect(tester.widget<Text>(roomsText).data, "2");
      expect(tester.widget<Text>(metricText).data, "100.00m²");
      expect(tester.widget<Text>(typologyText).data, "typology");
      expect(tester.widget<Text>(typeText).data, " land");

      expect(tester.widget<Text>(paymentPlanNameText).data, "Payment Plan");
      expect(tester.widget<Text>(serieUpfrontText).data,
          "10x R\$ 1,000.00 = R\$ 10,000.00");
      expect(tester.widget<Text>(serieMonthlyText).data,
          "5x R\$ 1,000.00 = R\$ 5,000.00");
    });

    testWidgets("Should show all information - modifiedPaymentPlan",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _createWidget(
          development: Development()
            ..name = "Development name"
            ..type = "land"
            ..address = (Address()
              ..streetAddress = "Street"
              ..number = "10"
              ..neighborhood = "neighborhood"
              ..city = "city"
              ..state = "state"
              ..zipCode = "00000-000"),
          proposal: Proposal()
            ..development = (DevelopmentReference()..name = "Development name")
            ..unit = (ProposalUnit()
              ..name = "Unit name"
              ..developmentUnit = (Unit()
                ..room = 2
                ..typology = "typology"
                ..type = "land"
                ..area = (UnitArea()..privateSquareMeters = 100)
                ..block = (Reference()..name = "blockName")))
            ..modifiedPaymentPlan = (PaymentPlan()
              ..name = "Modified Plan"
              ..series = <PaymentSeries>[
                PaymentSeries()
                  ..type = SeriesTypes.upfront
                  ..numberOfPayments = 1
                  ..prices = (PaymentSeriesPrices()
                    ..nominal = (SeriesPrices()
                      ..seriesValue = 1000
                      ..seriesTotal = 1000)),
                PaymentSeries()
                  ..type = SeriesTypes.monthly
                  ..numberOfPayments = 2
                  ..prices = (PaymentSeriesPrices()
                    ..nominal = (SeriesPrices()
                      ..seriesValue = 1000
                      ..seriesTotal = 2000)),
              ])
            ..paymentPlan = (PaymentPlan()
              ..name = "Payment Plan"
              ..series = <PaymentSeries>[
                PaymentSeries()
                  ..type = SeriesTypes.upfront
                  ..numberOfPayments = 10
                  ..prices = (PaymentSeriesPrices()
                    ..nominal = (SeriesPrices()
                      ..seriesValue = 1000
                      ..seriesTotal = 10000)),
                PaymentSeries()
                  ..type = SeriesTypes.monthly
                  ..numberOfPayments = 5
                  ..prices = (PaymentSeriesPrices()
                    ..nominal = (SeriesPrices()
                      ..seriesValue = 1000
                      ..seriesTotal = 5000)),
              ]),
        ),
      );

      expect(tester.widget<Text>(developmentNameText).data, "Development name");
      expect(tester.widget<Text>(addressText).data,
          "Street, 10 - neighborhood - city - state - 00000-000");

      expect(tester.widget<Text>(roomsText).data, "2");
      expect(tester.widget<Text>(metricText).data, "100.00m²");
      expect(tester.widget<Text>(typologyText).data, "typology");
      expect(tester.widget<Text>(typeText).data, " land");

      expect(tester.widget<Text>(paymentPlanNameText).data, "Modified Plan");
      expect(tester.widget<Text>(serieUpfrontText).data,
          "1x R\$ 1,000.00 = R\$ 1,000.00");
      expect(tester.widget<Text>(serieMonthlyText).data,
          "2x R\$ 1,000.00 = R\$ 2,000.00");
    });
  });
}
