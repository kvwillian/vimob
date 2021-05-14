import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/proposal/proposal_detail_page.dart';

class LinkBuyerDialog extends StatelessWidget {
  const LinkBuyerDialog({
    Key key,
    @required this.proposal,
  }) : super(key: key);

  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        height: Style.horizontal(45),
        width: Style.horizontal(80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(Style.horizontal(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: Style.horizontal(4)),
                    child: Text(
                      I18n.of(context).addAClient,
                      style: Style.mainTheme.textTheme.headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(I18n.of(context).addAClientText),
                ],
              ),
            ),
            Center(
              child: SizedBox(
                height: Style.horizontal(13),
                width: double.infinity,
                child: OutlineButton(
                  borderSide: BorderSide.none,
                  key: Key("dialog_link_buyer_button"),
                  onPressed: () {
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    _openProposalDetail(context);
                  },
                  child: Text(
                    "Ok",
                    style: Style.mainTheme.textTheme.button.copyWith(
                        color: Style.textButtonColorLink,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProposalDetail(BuildContext context) {
    var developments = Provider.of<DevelopmentState>(context, listen: false)
        .developments
        .value;

    Development development = developments.singleWhere(
        (development) => development.id == proposal.development.id);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProposalDetailPage(
                  proposal: proposal,
                  development: development,
                  initialIndex: 2,
                )));
  }
}

class InfoDialog extends StatelessWidget {
  const InfoDialog({
    Key key,
    @required this.text,
    @required this.title,
  }) : super(key: key);

  final String text;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        height: Style.horizontal(45),
        width: Style.horizontal(80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(Style.horizontal(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: Style.horizontal(4)),
                    child: Text(
                      title,
                      style: Style.mainTheme.textTheme.headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(text),
                ],
              ),
            ),
            Center(
              child: SizedBox(
                height: Style.horizontal(13),
                width: double.infinity,
                child: OutlineButton(
                  borderSide: BorderSide.none,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Ok",
                    style: Style.mainTheme.textTheme.button.copyWith(
                        color: Style.textButtonColorLink,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
