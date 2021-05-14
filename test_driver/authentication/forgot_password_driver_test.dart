import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../main_test.dart';

void forgotPasswordDriverTest() {
  group("Reset password |", () {
    var forgotPasswordButton = find.byValueKey("forgot_password_button");
    var textfieldCpf = find.byValueKey("textfield_cpf");
    var sendResetPasswordButton = find.byValueKey("send_reset_password_button");
    var txtSnackError = find.byValueKey("snackbar_text");
    var resetPasswordSentButton = find.byValueKey("reset_password_sent_button");

    test("Click on 'forgot password'", () async {
      await driver().tap(forgotPasswordButton);
    });

    test("Should show snackbar error (wrong cpf)", () async {
      await driver().tap(textfieldCpf);
      await driver().enterText("111.111.111-11");
      await driver().tap(sendResetPasswordButton);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "User not found");
      await driver().waitForAbsent(txtSnackError);
    });

    test("Should show snackbar error (user not found)", () async {
      await driver().tap(textfieldCpf);
      await driver().enterText("380.349.688-89");
      await driver().tap(sendResetPasswordButton);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "User not found");
      await driver().waitForAbsent(txtSnackError);
    });

    test("Should send email", () async {
      await driver().tap(textfieldCpf);
      await driver().enterText("791.457.050-89");
      await driver().tap(sendResetPasswordButton);
    });

    test("Should back to login", () async {
      await driver().tap(resetPasswordSentButton);
    });
  });
}
