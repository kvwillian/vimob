import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../main_test.dart';

clientTabDriverTest() {
  group("Client integration | ", () {
    var clientTab = find.byValueKey("client_tab");
    var searchClient = find.byValueKey("search_client");
    var searchClientInput = find.byType("TextField");
    var exitSearchClient = find.byValueKey("exit_search_client");
    var buyerCard0 = find.byValueKey("buyer_card_0");
    var buyerCard1 = find.byValueKey("buyer_card_1");
    var buyerCard2 = find.byValueKey("buyer_card_2");
    var buyerCard3 = find.byValueKey("buyer_card_3");
    var buyerCard4 = find.byValueKey("buyer_card_4");
    var openEditMode = find.byValueKey("open_edit_mode");
    var addBuyerButton = find.byValueKey("add_buyer_button");
    var buyerNameTextField = find.byValueKey("buyer_name_text_field");
    var buyerCpfCnpjTextField = find.byValueKey("buyer_cpf_cnpj_text_field");
    var buyerPhoneTextField = find.byValueKey("buyer_phone_text_field");
    var buyerEmailTextField = find.byValueKey("buyer_email_text_field");
    var buyerZipCodeTextField = find.byValueKey("buyer_zip_code_text_field");
    var buyerNumberTextField = find.byValueKey("buyer_number_text_field");
    var buyerComplementTextField =
        find.byValueKey("buyer_complement_text_field");
    var buyerNoteTextField = find.byValueKey("buyer_note_text_field");
    var editBuyerButton = find.byValueKey("edit_buyer_button");
    var editingCancel = find.byValueKey("editing_cancel");
    var back = find.byValueKey("arrow_back");
    var buyerPageCreate = find.byValueKey("buyer_page_create");

    test("Open client list", () async {
      await driver().tap(clientTab);
    });
    test("Should find 5 buyer cards", () async {
      await driver().waitFor(buyerCard0);
      await driver().waitFor(buyerCard1);
      await driver().waitFor(buyerCard2);
      await driver().waitFor(buyerCard3);
      await driver().waitFor(buyerCard4);
    });
    test("Should search a client", () async {
      await driver().tap(searchClient);
      await driver().tap(searchClientInput);
      await driver().enterText("Flutter");
      await driver().waitFor(buyerCard0);
    });
    test("Should back to client list", () async {
      await driver().tap(exitSearchClient);
    });

    group("Editing a buyer | ", () {
      test("Should edit a client", () async {
        await driver().tap(buyerCard0);
        await driver().waitFor(find.text("Dart"));
        await driver().waitFor(find.text("236.346.667-57"));
        await driver().waitFor(find.text("(12) 34567-8988"));
        await driver().tap(openEditMode);
      });
      test("Should show some errors", () async {
        await driver().tap(buyerNameTextField);
        await driver().enterText("");
        await driver().waitFor(find.text("Name invalid"));
        await driver().tap(buyerCpfCnpjTextField);
        await driver().enterText("");
        await driver().waitFor(find.text("CPF/CNPJ invalid"));
        await driver().enterText("000.000.000-00");
        await driver().waitFor(find.text("CPF/CNPJ invalid"));
        await driver().enterText("00.000.000/0000-00");
        await driver().waitFor(find.text("CPF/CNPJ invalid"));
        await driver().tap(buyerPhoneTextField);
        await driver().enterText("");
        await driver().waitFor(find.text("Phone invalid"));
        await driver().tap(buyerEmailTextField);
        await driver().enterText("email@email.com");

        await driver()
            .scroll(buyerEmailTextField, 0, -500, Duration(milliseconds: 500));

        await driver().tap(buyerZipCodeTextField);
        await driver().enterText("18056-580");
        await driver().waitFor(find.text("Rua João José Duarte"));
        await driver().waitFor(find.text("Jardim São Marcos"));
        await driver().waitFor(find.text("Sorocaba"));
        await driver().waitFor(find.text("SP"));
        await driver().waitFor(find.text("18056-580"));
        await driver().tap(buyerNumberTextField);
        await driver().enterText("100");
        await driver().tap(buyerComplementTextField);
        await driver().enterText("casa");
        await driver().tap(buyerNoteTextField);
        await driver().enterText("Description");
        await driver().tap(editBuyerButton);
        await driver().tap(editingCancel);

        await driver()
            .scroll(buyerEmailTextField, 0, 500, Duration(milliseconds: 500));

        await driver().waitFor(find.text("Dart"));
        await driver().waitFor(find.text("236.346.667-57"));
        await driver().waitFor(find.text("(12) 34567-8988"));
      });

      test("Should edit buyer information", () async {
        await driver().tap(openEditMode);
        await driver().tap(buyerCpfCnpjTextField);
        await driver().enterText("628.433.770-13");
        await driver().tap(buyerPhoneTextField);
        await driver().enterText("(15) 91234-1234");
        await driver().tap(editBuyerButton);

        await driver().waitFor(find.text("Dart"));
        await driver().waitFor(find.text("628.433.770-13"));
        await driver().waitFor(find.text("(15) 91234-1234"));
      });
      test("Should update to old information", () async {
        await driver().tap(openEditMode);
        await driver().tap(buyerNameTextField);
        await driver().enterText("Dart");
        await driver().tap(buyerCpfCnpjTextField);
        await driver().enterText("236.346.667-57");
        await driver().tap(buyerPhoneTextField);
        await driver().enterText("(12) 34567-8988");
        await driver().tap(editBuyerButton);

        await driver().waitFor(find.text("Dart"));
        await driver().waitFor(find.text("236.346.667-57"));
        await driver().waitFor(find.text("(12) 34567-8988"));
      });

      test("Exit", () async {
        await driver().tap(back);
      });
    });
    test("Should open create client page ", () async {});
    group("Create client page | ", () {
      test("Should open buyer page", () async {
        await driver().tap(addBuyerButton);
      });
      test("Should fill the fields", () async {
        await driver().tap(buyerNameTextField);
        await driver().enterText("Dart > React Native");
        await driver().tap(buyerCpfCnpjTextField);
        await driver().enterText("628.433.770-13");
        await driver().tap(buyerPhoneTextField);
        await driver().enterText("(00) 00000-0000");
        await driver().tap(buyerPageCreate);
      });
    });
  });
}
