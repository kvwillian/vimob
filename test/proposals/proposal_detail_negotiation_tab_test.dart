import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vimob/i18n/test_i18n_delegate.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/proposal/history.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/proposal/proposal_detail_negotiation_tab.dart';

void main() {
  Widget _createWidget(
      {Proposal proposal, BehaviorSubject<List<History>> proposalLogs}) {
    return LayoutBuilder(builder: (context, constraints) {
      Style().responsiveInit(constraints: constraints);
      Style.devicePixelRatio = window.devicePixelRatio;
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ProposalState>.value(
              value: ProposalState()..proposalLogs = proposalLogs),
          ChangeNotifierProvider<CompanyState>.value(
              value: CompanyState()
                ..companyStatuses = (CompanyStatuses()
                  ..proposals = <String, CompanyStatusConfig>{
                    'locked': (CompanyStatusConfig()
                      ..color = Color(0xFFAAAAAA)
                      ..enUS = "locked"
                      ..ptBR = "fechado"),
                  })),
        ],
        child: MaterialApp(
          localizationsDelegates: [
            TestI18nDelegate(),
          ],
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('pt', 'BR'),
          ],
          home: Material(
            child: ProposalDetailNegotiationTab(
              proposal: proposal,
            ),
          ),
        ),
      );
    });
  }

  group("Proposal detail negociation tab | ", () {
    var paymentPlanNameText =
        find.byKey(Key("proposal_detail_negotiation_payment_plan_name"));
    var totalValue = find.byKey(Key("proposal_detail_negotiation_total"));
    testWidgets("Should show all information", (WidgetTester tester) async {
      await tester.pumpWidget(_createWidget(
        proposal: Proposal()
          ..development = (DevelopmentReference()..id = "id")
          ..status = "locked"
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
        proposalLogs: BehaviorSubject<List<History>>.seeded([
          History()
            ..color = Colors.green
            ..date = Jiffy([2020, 1, 1, 1, 0])
            ..descriptionPtBr = "Created"
            ..title = "headline6"
            ..status = "status"
        ]),
      ));

      expect(tester.widget<Text>(paymentPlanNameText).data, "Payment Plan");
      expect(tester.widget<Text>(totalValue).data, "R\$ 15,000.00");
    });
  });
}
