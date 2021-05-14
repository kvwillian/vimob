import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../main_test.dart';

void changePasswordDriverTest() {
  group("Change password |", () {
    var changePasswordSendButton =
        find.byValueKey("change_password_send_button");
    var currentPasswordTextfield =
        find.byValueKey("current_password_textfield");
    var newPasswordTextfield = find.byValueKey("new_password_textfield");
    var repeatPasswordTextfield = find.byValueKey("repeat_password_textfield");
    var arrowBack = find.byValueKey("arrow_back");
    var homePage = find.byValueKey("home_page");
    var txtSnackError = find.byValueKey("snackbar_text");
    var changePasswordButton = find.byValueKey("change_password_button");

    test("Open change password page", () async {
      await driver().tap(changePasswordButton);
    });
    test("Should get error(Fields are required)", () async {
      await driver().tap(changePasswordSendButton);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "Fields are required");
      await driver().waitForAbsent(txtSnackError);
    });
    test("Should get error(wrong password)", () async {
      await driver().tap(currentPasswordTextfield);
      await driver().enterText("wrongPassword");
      await driver().tap(newPasswordTextfield);
      await driver().enterText("wrongPassword2");
      await driver().tap(repeatPasswordTextfield);
      await driver().enterText("wrongPassword2");

      await driver().tap(changePasswordSendButton);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "Wrong password");
      await driver().waitForAbsent(txtSnackError);
    });
    test("Back to home page", () async {
      await driver().tap(arrowBack);
      await driver().tap(arrowBack);
      await driver()
          .scroll(homePage, -300.0, 0.0, const Duration(milliseconds: 300));
    });
  });
}
