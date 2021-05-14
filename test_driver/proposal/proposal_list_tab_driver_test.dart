import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../main_test.dart';

void proposalListTabDriverTest() {
  group("Proposal page |", () {
    var proposalPage = find.byValueKey("proposal_tab");
    var searchProposal = find.byValueKey("search_proposal");
    var searchProposalInput = find.byType("TextField");
    var proposalCard0 = find.byValueKey("proposal_card_0");
    var proposalCard1 = find.byValueKey("proposal_card_1");
    var proposalCard2 = find.byValueKey("proposal_card_2");
    var exitSearchProposal = find.byValueKey("exit_search_proposal");
    var arrowBack = find.byValueKey("arrow_back");
    test("Open page", () async {
      await driver().tap(proposalPage);
    });
    test("Should find proposal cards", () async {
      await driver().waitFor(proposalCard0);
      await driver().waitFor(proposalCard1);
      await driver().waitFor(proposalCard2);
    });

    group("Search proposals |", () {
      test("Should search a card", () async {
        await driver().tap(searchProposal);
        await driver().tap(searchProposalInput);
      });
      test("Should enter text", () async {
        await driver().enterText('avaliation');
      });
      test("Should find a card", () async {
        await driver().waitForAbsent(proposalCard1);
        await driver().waitForAbsent(proposalCard2);
      });

      test("Should exit search", () async {
        await driver().tap(exitSearchProposal);
      });
    });

    group("Filter proposasl |", () {
      var filterProposalsButton = find.byValueKey("filter_proposals_button");
      var checkBoxAvaliation = find.byValueKey("check_box_avaliation");
      var applyFilterButton = find.byValueKey("apply_filter_button");
      var cleanFilterButton = find.byValueKey("clean_filter_button");

      test("Open filter page", () async {
        await driver().tap(filterProposalsButton);
      });
      test("Apply filter", () async {
        await driver().tap(checkBoxAvaliation);
        await driver().tap(applyFilterButton);

        await driver().waitFor(proposalCard0);
        await driver().waitFor(proposalCard1);
      });

      test("clean filter", () async {
        await driver().tap(filterProposalsButton);
        await driver().tap(cleanFilterButton);
        await driver().tap(applyFilterButton);

        await driver().waitFor(proposalCard0);
        await driver().waitFor(proposalCard1);
        await driver().waitFor(proposalCard2);
      });
    });

    group("Proposal detail |", () {
      var proposalDetailClientTab =
          find.byValueKey("proposal_detail_client_tab");
      var proposalDetailNegociationTab =
          find.byValueKey("proposal_detail_negociation_tab");
      var proposalDetailInformationTab =
          find.byValueKey("proposal_detail_information_tab");
      var negociationHistoryTab = find.byValueKey("negotiation_history_tab");
      var negociationAttachmentsTab =
          find.byValueKey("negociation_attachments_tab");
      var openProposalDetailButton =
          find.byValueKey("open_proposal_detail_button");
      var sendProposalButton = find.byValueKey("send_proposal_button");
      var removeProposalButton = find.byValueKey("remove_proposal_button");
      var cancelProposalSendButton =
          find.byValueKey("cancel_proposal_send_button");
      var dialogLinkBuyerButton = find.byValueKey("dialog_link_buyer_button");
      // var downloadAttachmentButton =
      //     find.byValueKey("dowonload_attachment_button_356565.jpg");

      test("Open proposal detail with a tap and back", () async {
        await driver().tap(proposalCard0);
        await driver().tap(arrowBack);
      });

      test("Send proposal detail with long press(with buyer)", () async {
        await driver().scroll(proposalCard1, 0, 0, Duration(milliseconds: 500));
        await driver().tap(sendProposalButton);
        await driver().waitFor(find.text("Send proposal"));
        await driver().tap(cancelProposalSendButton);
        await driver().scroll(proposalCard1, 0, 0, Duration(milliseconds: 500));
      });
      test("Send proposal detail with long press(without buyer)", () async {
        await driver().scroll(proposalCard0, 0, 0, Duration(milliseconds: 500));
        await driver().tap(sendProposalButton);
        await driver().waitFor(find.text("Add a client"));
        await driver().tap(dialogLinkBuyerButton);
        await driver().waitFor(find.text("NEW CLIENT"));
        await driver().tap(arrowBack);
      });
      test("remove proposal detail with long press", () async {
        await driver().scroll(proposalCard0, 0, 0, Duration(milliseconds: 500));
        await driver().tap(removeProposalButton);
      });
      test("Open proposal detail with long press", () async {
        await driver().scroll(proposalCard0, 0, 0, Duration(milliseconds: 500));
        await driver().tap(openProposalDetailButton);
      });

      test("Switch tabs - Negociation", () async {
        await driver().tap(proposalDetailNegociationTab);
        await driver().tap(negociationHistoryTab);
        await driver().tap(negociationAttachmentsTab);
      });

      // group("Attachments |", () {
      //   test("Image preview", () async {
      //     await driver().tap(attachment1);
      //     await driver().waitFor(attachmentPreview);
      //     await driver().tap(arrowBack);
      //   });
      // });

      test("Switch tabs - Client", () async {
        await driver().tap(proposalDetailClientTab);
      });

      group("Create&Link / Change / Link / Unlink a client | ", () {
        var linkBuyerButton = find.byValueKey("link_buyer_button");
        var createAndLinkBuyerButton =
            find.byValueKey("create_and_link_buyer_button");
        var buyerNameTextField = find.byValueKey("buyer_name_text_field");
        var buyerCpfCnpjTextField =
            find.byValueKey("buyer_cpf_cnpj_text_field");
        var buyerPhoneTextField = find.byValueKey("buyer_phone_text_field");
        var buyerPageCreateAndLink =
            find.byValueKey("buyer_page_create_and_link");
        var fabMenu = find.byValueKey("fab_menu");
        var fabMenuChangeClient = find.byValueKey("fab_menu_change_client");
        var buyerCard1 = find.byValueKey("buyer_card_1");
        var buyerCard0 = find.byValueKey("buyer_card_0");
        var fabMenuUnlinkClient = find.byValueKey("fab_menu_unlink_client");
        test("Create and link", () async {
          await driver().tap(createAndLinkBuyerButton);
          await driver().tap(buyerNameTextField);
          await driver().enterText("TestClient");
          await driver().tap(buyerCpfCnpjTextField);
          await driver().enterText("306.615.880-25");
          await driver().tap(buyerPhoneTextField);
          await driver().enterText("(00) 00000-0000");
          await driver().tap(buyerPageCreateAndLink);

          await driver().waitFor(find.text("TestClient"));
        });
        test("Change", () async {
          await driver().tap(fabMenu);
          await driver().tap(fabMenuChangeClient);
          await driver().tap(buyerCard0);
          await driver().waitFor(find.text("Dart"));
        });
        test("Unlink", () async {
          await driver().tap(fabMenu);
          await driver().tap(fabMenuUnlinkClient);
        });
        test("Link", () async {
          await driver().tap(linkBuyerButton);
          await driver().tap(buyerCard1);

          await driver().waitFor(find.text("Flutter"));
        });
        test("Unlink", () async {
          await driver().tap(fabMenu);

          await driver().tap(fabMenuUnlinkClient);
        });
      });

      test("Switch tabs - Information", () async {
        await driver().tap(proposalDetailInformationTab);
      });

      test("Exit", () async {
        await driver().tap(arrowBack);
      });
    });

    group("Create a proposal | ", () {
      var createProposalButton = find.byValueKey("create_proposal_button");
      var searchDevelopment = find.byValueKey("search_development");
      var exitSearchDevelopment = find.byValueKey("exit_search_development");
      var filterUnitsButton = find.byValueKey("filter_units_button");
      var exitFilterButton = find.byValueKey("exit_filter_button");
      var exitUnitPageButton = find.byValueKey("exit_unit_page_button");
      var applyFilterButton = find.byValueKey("apply_filter_button");
      var cleanFilterButton = find.byValueKey("clean_filter_button");
      var filterRoom1 = find.byValueKey("room_1");

      test("Open development list", () async {
        await driver().tap(createProposalButton);
        await driver().waitFor(find.text("VERONA RESIDENCE"));
        await driver().waitFor(find.text("JARDIM PINHEIROS"));
      });
      test("Open search development list", () async {
        await driver().tap(searchDevelopment);
        await driver().waitFor(find.text("VERONA RESIDENCE"));
        await driver().waitFor(find.text("JARDIM PINHEIROS"));
      });
      test("Type search development list", () async {
        await driver().tap(find.byType("TextField"));
        await driver().enterText("VER");
        await driver().waitFor(find.text("VERONA RESIDENCE"));
      });
      test("Exit search development list", () async {
        await driver().tap(exitSearchDevelopment);
      });

      test("Open unit list", () async {
        await driver().tap(find.text("VERONA RESIDENCE"));
      });
      test("Open filter of unit list", () async {
        await driver().tap(filterUnitsButton);
      });
      test("exit filter", () async {
        await driver().tap(exitFilterButton);
      });
      test("Open filter of unit list and scroll to rooms section", () async {
        await driver().tap(filterUnitsButton);
        await driver().scroll(
            find.byType("ListView"), 0, -1500, Duration(milliseconds: 500));
      });
      test("Select filter rooms", () async {
        await driver().tap(filterRoom1);
      });
      test("Apply filter", () async {
        await driver().tap(applyFilterButton);
      });
      // test("Should find a card", () async {
      //   await driver().waitFor(find.text("004"));
      // });

      test("Open filter, clean filter and apply", () async {
        await driver().tap(filterUnitsButton);
        await driver().tap(cleanFilterButton);
        await driver().tap(applyFilterButton);
      });
      test("Should find cards", () async {
        await driver().waitFor(find.text("10º floor"));
      });

      test("Exit Temporary", () async {
        await driver().tap(exitUnitPageButton);
      });
    });
  });
}
