import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../main_test.dart';

void changeEmailDriverTest() {
  group("Change email", () {
    var profileEditModeButton = find.byValueKey("profile_edit_mode_button");
    var profileEditEmailButton = find.byValueKey("profile_edit_email_button");
    var changeEmailDialogButton = find.byValueKey("change_email_dialog_button");
    var changeEmailDialogBackButton =
        find.byValueKey("change_email_dialog_back_button");
    var changeEmailSendButton = find.byValueKey("change_email_send_button");
    var passwordTextfield = find.byValueKey("password_textfield");
    var newEmailTextfield = find.byValueKey("new_email_textfield");
    var arrowBack = find.byValueKey("arrow_back");
    var profileSendUpdateButton = find.byValueKey("profile_send_update_button");
    var txtSnackError = find.byValueKey("snackbar_text");

    test("Should open dialog", () async {
      await driver().tap(profileEditModeButton);
      await driver().tap(profileEditEmailButton);
    });
    test("Should ope new page", () async {
      await driver().tap(changeEmailDialogButton);
    });

    test("Should get error(Fields are required)", () async {
      await driver().tap(changeEmailSendButton);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "Fields are required");
      await driver().waitForAbsent(txtSnackError);
    });
    test("Should get error(Wrong password)", () async {
      await driver().tap(newEmailTextfield);
      await driver().enterText("newemail@email.com");
      await driver().tap(passwordTextfield);
      await driver().enterText("9999999");

      await driver().tap(changeEmailSendButton);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "Wrong password");
      await driver().waitForAbsent(txtSnackError);
    });
    test("Should get error(Email already in use)", () async {
      await driver().tap(newEmailTextfield);
      await driver().enterText("giuliano.stravini@mega.com.br");
      await driver().tap(passwordTextfield);
      await driver().enterText("123456");

      await driver().tap(changeEmailSendButton);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "E-mail already in use");
      await driver().waitForAbsent(txtSnackError);
    });

    test("Back to profile page", () async {
      await driver().tap(arrowBack);
      await driver().tap(changeEmailDialogBackButton);
      await driver().tap(profileSendUpdateButton);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "Success");
      await driver().waitForAbsent(txtSnackError);
    });
  });
}
