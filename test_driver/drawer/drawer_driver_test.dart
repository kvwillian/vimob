import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../main_test.dart';

void drawerDriverTest() {
  var drawer = find.byValueKey("drawer");
  // var back = find.byValueKey("arrow_back");
  var homePage = find.byValueKey("home_page");
  // var helpPage = find.byValueKey("help_page");
  var dropdownButtonCompanies = find.byValueKey("dropdown_button_companies");
  var dropdownCompany1 = find.text("Vimob Demonstração");
  var dropdownCompany2 = find.text("Company Test");
  group("Swicth companies |", () {
    test("Should change company", () async {
      await driver().tap(drawer);
      await driver().tap(dropdownButtonCompanies);
      await driver().waitFor(dropdownCompany2);
      await driver().tap(dropdownCompany2);
      await driver()
          .scroll(homePage, -300.0, 0.0, const Duration(milliseconds: 300));
    });

    test("Should change to first company", () async {
      await driver().tap(drawer);
      await driver().tap(dropdownButtonCompanies);
      await driver().waitFor(dropdownCompany1);
      await driver().tap(dropdownCompany1);
      await driver()
          .scroll(homePage, -300.0, 0.0, const Duration(milliseconds: 300));
    });

    test("Should have developments ", () async {
      await driver().waitFor(find.byValueKey("development_card_0"));
    });
  });

  // group("Help page", () {
  //   test("Should open Help page", () async {
  //     await driver().tap(drawer);
  //     await driver().tap(helpPage);

  //     await driver().tap(back);
  //     await driver()
  //         .scroll(homePage, -300.0, 0.0, const Duration(milliseconds: 300));
  //   });
  // });
}
