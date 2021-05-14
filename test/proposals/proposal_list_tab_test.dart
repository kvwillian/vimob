import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vimob/i18n/test_i18n_delegate.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/proposal/proposal_card.dart';
import 'package:vimob/ui/proposal/proposal_list_tab.dart';

void main() {
  Widget _createProposalListTab(
      {@required BehaviorSubject<List<Proposal>> proposalList}) {
    var porposalState = ProposalState()..currentProposals = proposalList;

    var companyStatutes = CompanyStatuses()
      ..proposals = <String, CompanyStatusConfig>{
        'avaliation': (CompanyStatusConfig()
          ..color = Color(0xFFFFFFAF)
          ..enUS = "avaliation"
          ..ptBR = "avaliando")
      };

    var companyState = CompanyState()..companyStatuses = companyStatutes;

    return LayoutBuilder(builder: (context, constraints) {
      Style().responsiveInit(constraints: constraints);
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: porposalState),
          ChangeNotifierProvider.value(value: companyState),
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
                child: ProposalListTab(
              proposalState: porposalState,
              user: User(),
            ))),
      );
    });
  }

  var proposalListEmptyIcon = find.byKey(Key("proposal_list_empty_icon"));
  group("Proposal list tab |", () {
    testWidgets("Normal list. Should show a card", (WidgetTester tester) async {
      var porposlaList = BehaviorSubject<List<Proposal>>.seeded(
        <Proposal>[
          Proposal()
            ..status = "avaliation"
            ..development = (DevelopmentReference()..name = "Jardins")
            ..block = (Reference()..name = "bloco a")
            ..unit = (ProposalUnit()..name = "a10")
            ..date = Jiffy([2019, 1, 1])
            ..idProposalMega = 321654
        ],
      );

      await tester.pumpWidget(
        _createProposalListTab(proposalList: porposlaList),
      );

      await tester.pump(Duration.zero);

      expect(find.byType(ProposalCard), findsOneWidget);
      porposlaList.close();
    });

    group("Proposal list tab |", () {
      testWidgets("Normal list. Should show cards",
          (WidgetTester tester) async {
        var proposalList = BehaviorSubject<List<Proposal>>.seeded(
          <Proposal>[
            Proposal()
              ..status = "avaliation"
              ..development = (DevelopmentReference()..name = "Jardins")
              ..block = (Reference()..name = "bloco a")
              ..unit = (ProposalUnit()..name = "a10")
              ..date = Jiffy([2019, 1, 1])
              ..idProposalMega = 321654,
            Proposal()
              ..status = "avaliation"
              ..development = (DevelopmentReference()..name = "Jardins")
              ..block = (Reference()..name = "bloco a")
              ..unit = (ProposalUnit()..name = "a10")
              ..date = Jiffy([2019, 1, 1])
              ..idProposalMega = 123123,
          ],
        );

        await tester.pumpWidget(
          _createProposalListTab(proposalList: proposalList),
        );

        await tester.pump(Duration.zero);

        expect(find.byType(ProposalCard), findsNWidgets(2));
        proposalList.close();
      });
    });

    testWidgets("Empty list. Should show feedback message",
        (WidgetTester tester) async {
      await tester.pumpWidget(_createProposalListTab(
          proposalList: BehaviorSubject<List<Proposal>>.seeded(<Proposal>[])));

      await tester.pump(Duration.zero);

      expect(find.byType(ProposalCard), findsNothing);
      expect(proposalListEmptyIcon, findsOneWidget);
    });
  });
}
