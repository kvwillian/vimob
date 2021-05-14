import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/states/buyer_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/clients/buyer_page.dart';
import 'package:vimob/ui/clients/client_list_tab.dart';

class LinkBuyerTab extends StatelessWidget {
  const LinkBuyerTab({
    Key key,
    this.proposal,
  }) : super(key: key);

  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      padding: EdgeInsets.symmetric(horizontal: Style.horizontal(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/clients/buyer_default.png",
            width: Style.horizontal(60),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: Style.horizontal(6)),
            child: Text(
              I18n.of(context).linkAClientText,
              style: Style.mainTheme.textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: Style.horizontal(4)),
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                key: Key("create_and_link_buyer_button"),
                color: Colors.blue,
                textColor: Style.textButtonColorPrimary,
                onPressed: () {
                  Provider.of<BuyerState>(context, listen: false).isEditing =
                      true;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BuyerPage(
                                buyer: null,
                                proposal: proposal,
                                mode: BuyerAppBarMode.createAndLink,
                              )));
                },
                child: Text(I18n.of(context).newClient.toUpperCase()),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlineButton(
              key: Key("link_buyer_button"),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClientListTab(
                              isListLinkBuyer: true,
                              proposal: proposal,
                            )));
              },
              child: Text(I18n.of(context).linkExistingClient.toUpperCase()),
            ),
          )
        ],
      ),
    );
  }
}
