import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../main_test.dart';
import 'change_email_driver_test.dart';
import 'change_password_driver_test.dart';

void profileDriverTest() {
  group("Profile Integration | ", () {
    var drawer = find.byValueKey("drawer");
    var drawerProfileImage = find.byValueKey("profile_image");
    var profileSendUpdateButton = find.byValueKey("profile_send_update_button");
    var profileEditModeButton = find.byValueKey("profile_edit_mode_button");
    var nameTextfield = find.byValueKey("name_textfield");
    var lastNameTextfield = find.byValueKey("last_name_textfield");
    var txtSnackError = find.byValueKey("snackbar_text");

    test("Open Drawer", () async {
      await driver().tap(drawer);
    });

    test("Open Profile page", () async {
      await driver().tap(drawerProfileImage);
    });

    test("Enter edit mode", () async {
      await driver().tap(profileEditModeButton);
    });

    test("Should get error(Fields are required)", () async {
      await driver().tap(nameTextfield);
      await driver().enterText("");
      await driver().tap(lastNameTextfield);
      await driver().enterText("");

      await driver().tap(profileSendUpdateButton);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "Fields are required");
      await driver().waitForAbsent(txtSnackError);
    });
    test("Should update information and exit of edit moode", () async {
      await driver().tap(nameTextfield);
      await driver().enterText("Giu");
      await driver().tap(lastNameTextfield);
      await driver().enterText("Stravini");

      await driver().tap(profileSendUpdateButton);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "Success");
      await driver().waitForAbsent(txtSnackError);
    });

    changeEmailDriverTest();

    changePasswordDriverTest();
  });
}
