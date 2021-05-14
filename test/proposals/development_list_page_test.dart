import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vimob/i18n/test_i18n_delegate.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/proposal/development_list_page.dart';
import 'package:vimob/ui/proposal/proposal_development_card.dart';

void main() {
  group("Development List Page | ", () {
    Widget _createDevelopmentCard(
        {BehaviorSubject<List<Development>> developments}) {
      return LayoutBuilder(builder: (context, constraints) {
        Style().responsiveInit(constraints: constraints);
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<DevelopmentState>.value(
                value: DevelopmentState()..developments = developments),
            ChangeNotifierProvider<AuthenticationState>.value(
                value: AuthenticationState()
                  ..user = (User()..company = "companyId")),
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
              child: DevelopmentListPage(),
            ),
          ),
        );
      });
    }

    var circularProgress = find.byType(CircularProgressIndicator);
    var proposalDevelopmentCard = find.byType(ProposalDevelopmentCard);

    testWidgets("Should show circular progress - list null",
        (WidgetTester tester) async {
      await tester.pumpWidget(_createDevelopmentCard(
          developments: BehaviorSubject<List<Development>>.seeded(null)));

      await tester.pump();
      expect(circularProgress, findsOneWidget);
      expect(proposalDevelopmentCard, findsNothing);
    });

    testWidgets("Should show nothing - list empty",
        (WidgetTester tester) async {
      await tester.pumpWidget(_createDevelopmentCard(
          developments:
              BehaviorSubject<List<Development>>.seeded(<Development>[])));

      await tester.pump();
      expect(circularProgress, findsNothing);
      expect(proposalDevelopmentCard, findsNothing);
    });
    testWidgets("Should show 2 development", (WidgetTester tester) async {
      await tester.pumpWidget(_createDevelopmentCard(
          developments: BehaviorSubject<List<Development>>.seeded(<Development>[
        Development()
          ..id = "developmentId0"
          ..type = "land"
          ..name = "Development name 0"
          ..numberOfAvailableUnits = 10,
        Development()
          ..id = "developmentId1"
          ..type = "land"
          ..name = "Development name 1"
          ..numberOfAvailableUnits = 10,
        Development()
          ..id = "developmentId2"
          ..type = "land"
          ..name = "Development name 2"
          ..numberOfAvailableUnits = 10,
      ])));

      await tester.pumpAndSettle();
      expect(circularProgress, findsNothing);
      expect(proposalDevelopmentCard, findsNWidgets(3));
    });
  });
}
