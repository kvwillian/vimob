import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/buyer/buyer.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/states/buyer_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/clients/buyer_card.dart';
import 'package:vimob/ui/clients/buyer_page.dart';
import 'package:vimob/ui/clients/buyer_search_delegate.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';

class ClientListTab extends StatelessWidget {
  const ClientListTab({
    Key key,
    @required this.isListLinkBuyer,
    this.proposal,
  }) : super(key: key);

  final bool isListLinkBuyer;
  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    var buyerState = Provider.of<BuyerState>(context);

    return Scaffold(
      appBar: !isListLinkBuyer
          ? null
          : AppBarResponsive().show(
              context: context,
              title: I18n.of(context).clients,
              actions: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: Style.horizontal(2)),
                    child: InkWell(
                        key: Key("search_client"),
                        child: Icon(
                          Icons.search,
                          color: Style.mainTheme.appBarTheme.iconTheme.color,
                          size: Style.mainTheme.appBarTheme.iconTheme.size,
                        ),
                        onTap: () async {
                          await showSearch(
                              context: context,
                              delegate: BuyerSearchDelegate(
                                  BuyerState().buyersList.value));
                        }),
                  )
                ]),
      floatingActionButton: isListLinkBuyer
          ? null
          : SizedBox(
              width: Style.horizontal(15),
              height: Style.horizontal(15),
              child: FloatingActionButton(
                key: Key("add_buyer_button"),
                onPressed: () {
                  buyerState.isEditing = true;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BuyerPage(
                                buyer: null,
                                mode: BuyerAppBarMode.create,
                              )));
                },
                backgroundColor: Colors.green,
                child: Center(
                  child: Icon(Icons.add),
                ),
              ),
            ),
      body: StreamBuilder<List<Buyer>>(
          stream: buyerState.buyersList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                // color: Colors.black,
                child: Padding(
                  padding: EdgeInsets.only(top: Style.horizontal(4)),
                  child: ListView(
                    children: snapshot.data
                        .map((buyer) => BuyerCard(
                            key: Key(
                                "buyer_card_${snapshot.data.indexOf(buyer)}"),
                            onTap: () async {
                              if (isListLinkBuyer) {
                                try {
                                  await ProposalState().linkBuyer(
                                      buyer: buyer, proposal: proposal);

                                  Navigator.pop(context);
                                } catch (e) {}
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => BuyerPage(
                                              buyer: buyer,
                                              mode: BuyerAppBarMode.edit,
                                            )));
                              }
                            },
                            buyer: buyer))
                        .toList(),
                  ),
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      key: Key("client_list_empty_icon"),
                      size: Style.horizontal(30),
                      color: Style.mainTheme.iconTheme.color,
                    ),
                    Padding(
                      padding: EdgeInsets.all(Style.horizontal(4)),
                      child: Text(I18n.of(context).addYourFirstClient),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
