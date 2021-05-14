@Timeout(Duration(seconds: 10))

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../main_test.dart';

void inviteDriverTest() {
  group("Add a new company |", () {
    test("Open drawer and select option to uso the invite code", () async {
      await driver().tap(find.byValueKey("drawer"));
      await driver().tap(find.byValueKey("invite_page"));
    });
    test("Use the invite code", () async {
      await driver().tap(find.byValueKey("text_field_invite_code"));
      await driver().enterText("D32GI7");
      await driver().tap(find.byValueKey("btn_send_invite_code"));
      await driver().waitFor(find.byValueKey("development_card_0"));
    });
  });
}
