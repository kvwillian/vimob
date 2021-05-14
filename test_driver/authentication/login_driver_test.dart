@Timeout(Duration(seconds: 10))

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../main_test.dart';
import 'forgot_password_driver_test.dart';
import 'sign_up_driver_test.dart';

void authenticationDriverTest() {
  group("Login integration |", () {
    var textfieldCpf = find.byValueKey("textfield_cpf");
    var textfieldPassword = find.byValueKey("textfield_password");
    var btnSignIn = find.byValueKey("btn_sign_in");
    var txtSnackError = find.byValueKey("snackbar_text");

    test("Should show snackbar error(empty fields)", () async {
      await driver().tap(btnSignIn);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "User not found");
      await driver().waitForAbsent(txtSnackError);
    });
    test("Should show snackbar error(wrong cpf)", () async {
      await driver().tap(textfieldCpf);
      await driver().enterText("111.111.111-11");
      await driver().tap(textfieldPassword);
      await driver().enterText("megamega");
      await driver().tap(btnSignIn);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "User not found");
      await driver().waitForAbsent(txtSnackError);
    });
    test("Should show snackbar error(wrong password)", () async {
      await driver().tap(textfieldCpf);
      await driver().enterText("791.457.050-89");
      await driver().tap(textfieldPassword);
      await driver().enterText("megamega");
      await driver().tap(btnSignIn);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "Wrong password");
      await driver().waitForAbsent(txtSnackError);
    });

    signUpDriverTest();

    forgotPasswordDriverTest();

    test("Should signIn", () async {
      await driver().tap(textfieldCpf);
      await driver().enterText("791.457.050-89");
      await driver().tap(textfieldPassword);
      await driver().enterText("123456");
      await driver().tap(btnSignIn);
      await driver().waitFor(find.byValueKey("development_card_0"));
    });
  });
}
