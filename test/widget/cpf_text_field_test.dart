import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/cpf_text_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("Cpf textfield |", () {
    var authenticationState = AuthenticationState()..formStatus = FormStatus();
    testWidgets("Cpf format", (WidgetTester tester) async {
      await tester.pumpWidget(LayoutBuilder(builder: (context, constraints) {
        Style().responsiveInit(constraints: constraints);
        return MaterialApp(
          home: Material(
            child: ChangeNotifierProvider.value(
              value: AuthenticationState(),
              child: CpfTextField(
                  formStatus: authenticationState.formStatus,
                  onChanged: (String newValue) {
                    authenticationState.handleCpfValue(newValue: newValue);
                  }),
            ),
          ),
        );
      }));

      await tester.tap(find.byKey(Key("textfield_cpf")));
      await tester.enterText(find.byKey(Key("textfield_cpf")), "12312312312");
      String fieldValue = tester
          .widget<TextField>(find.byKey(Key("textfield_cpf")))
          .controller
          .text;

      expect(fieldValue, "123.123.123-12");
    }, timeout: Timeout(Duration(seconds: 5)));
  });
}
