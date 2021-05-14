import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/test_i18n_delegate.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/proposal/status_chip.dart';

void main() {
  group("Status chip | ", () {
    var statusChipText = find.byKey(Key("status_chip_text"));
    var statusChipInvisible = find.byKey(Key("status_chip_invisible"));

    testWidgets("Should show the chip", (WidgetTester tester) async {
      await tester.pumpWidget(LayoutBuilder(builder: (context, constraints) {
        Style().responsiveInit(constraints: constraints);
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
                value: CompanyState()
                  ..companyStatuses = (CompanyStatuses()
                    ..proposals = {
                      "available": CompanyStatusConfig()
                        ..color = Color(0xFFFFFFFF)
                        ..enUS = "available"
                        ..ptBR = "disponível"
                    }))
          ],
          child: MaterialApp(
            localizationsDelegates: [
              TestI18nDelegate(),
            ],
            supportedLocales: [
              const Locale('en', 'US'),
              const Locale('pt', 'BR'),
            ],
            home: StatusChip(
              status: "available",
            ),
          ),
        );
      }));

      expect(tester.widget<Text>(statusChipText).data, "available");
    });

    testWidgets("Should show nothing (status doesn't exist)",
        (WidgetTester tester) async {
      await tester.pumpWidget(LayoutBuilder(builder: (context, constraints) {
        Style().responsiveInit(constraints: constraints);
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
                value: CompanyState()
                  ..companyStatuses = (CompanyStatuses()
                    ..proposals = {
                      "available": CompanyStatusConfig()
                        ..color = Color(0xFFFFFFFF)
                        ..enUS = "available"
                        ..ptBR = "disponível"
                    }))
          ],
          child: MaterialApp(
            localizationsDelegates: [
              TestI18nDelegate(),
            ],
            supportedLocales: [
              const Locale('en', 'US'),
              const Locale('pt', 'BR'),
            ],
            home: StatusChip(
              status: "noStatus",
            ),
          ),
        );
      }));

      expect(statusChipInvisible, findsOneWidget);
    });

    testWidgets("Should show nothing (status null)",
        (WidgetTester tester) async {
      await tester.pumpWidget(LayoutBuilder(builder: (context, constraints) {
        Style().responsiveInit(constraints: constraints);
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
                value: CompanyState()
                  ..companyStatuses = (CompanyStatuses()
                    ..proposals = {
                      "available": CompanyStatusConfig()
                        ..color = Color(0xFFFFFFFF)
                        ..enUS = "available"
                        ..ptBR = "disponível"
                    }))
          ],
          child: MaterialApp(
            localizationsDelegates: [
              TestI18nDelegate(),
            ],
            supportedLocales: [
              const Locale('en', 'US'),
              const Locale('pt', 'BR'),
            ],
            home: StatusChip(
              status: null,
            ),
          ),
        );
      }));

      expect(statusChipInvisible, findsOneWidget);
    });
  });
}
