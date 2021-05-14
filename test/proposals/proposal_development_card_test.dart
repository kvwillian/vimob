import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/test_i18n_delegate.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/proposal/proposal_development_card.dart';

void main() {
  group("Proposal Development Card |", () {
    Widget _createDevelopmentCard({Development development, User user}) {
      return LayoutBuilder(builder: (context, constraints) {
        Style().responsiveInit(constraints: constraints);
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<DevelopmentState>.value(
                value: DevelopmentState()),
            ChangeNotifierProvider<AuthenticationState>.value(
                value: AuthenticationState()..user = user),
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
              child: ListView(children: <Widget>[
                ProposalDevelopmentCard(development: development),
              ]),
            ),
          ),
        );
      });
    }

    var proposalDevelopmentNameText =
        find.byKey(Key("proposal_development_name_text"));
    var proposalDevelopmentUnitsAvailableText =
        find.byKey(Key("proposal_development_units_available_text"));

    testWidgets("Should show a card with 10 units available",
        (WidgetTester tester) async {
      await tester.pumpWidget(_createDevelopmentCard(
          development: Development()
            ..id = "developmentId"
            ..type = "land"
            ..name = "Development name"
            ..numberOfAvailableUnits = 10,
          user: User()..company = "companyId"));
      expect(tester.widget<Text>(proposalDevelopmentNameText).data,
          "Development name");
      expect(tester.widget<Text>(proposalDevelopmentUnitsAvailableText).data,
          "10 developmentsAvailable");
    });
  });
}
