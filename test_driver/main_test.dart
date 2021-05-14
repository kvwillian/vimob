import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'authentication/login_driver_test.dart';

import 'client/client_tab_driver_test.dart';
import 'drawer/drawer_driver_test.dart';
import 'invite/invite_driver_test.dart';
import 'profile/profile_driver_test.dart';
import 'proposal/proposal_list_tab_driver_test.dart';

class Driver {
  FlutterDriver driver;
}

final driverInstance = Driver();
final driver = () => driverInstance.driver;

void main() {
  group('SetUp driver test |', () {
    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driverInstance.driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driverInstance.driver.close();
      }
    });

    //Sign up, forgot paswword and sign up
    authenticationDriverTest();

    //Development detail
    group("Sales mirror |", () {
      var developmentCard = find.byValueKey("development_card_2");
      var seeUnitsButton = find.byValueKey("see_units_button");
      var arrowBack = find.byValueKey("arrow_back");
      var carousel = find.byValueKey("carousel");

      test("Open details", () async {
        await driver().tap(developmentCard);
      });

      group("Carousel |", () {
        test("should slide carousel", () async {
          await driver().scroll(carousel, -500, 0, Duration(milliseconds: 500));
          await driver().scroll(carousel, -500, 0, Duration(milliseconds: 500));
          await driver().scroll(carousel, 500, 0, Duration(milliseconds: 500));
          await driver().scroll(carousel, 500, 0, Duration(milliseconds: 500));
        });
      });

      test("See units", () async {
        await driver().tap(seeUnitsButton);
      });

      test("Back", () async {
        await driver().tap(arrowBack);
        await driver().tap(arrowBack);
      });
    });

    //switch between companies
    drawerDriverTest();

    //Use a invite
    inviteDriverTest();

    //Update profile
    profileDriverTest();

    //Check proposals
    proposalListTabDriverTest();

    //Client
    clientTabDriverTest();

    //Exit
    test("Should signOut", () async {
      var signOutButton = find.byValueKey("sign_out_button");

      await driver().tap(find.byValueKey("drawer"));
      await driver().tap(signOutButton);
    });
  });
}
