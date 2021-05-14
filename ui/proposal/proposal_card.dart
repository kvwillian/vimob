import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/proposal/link_buyer_dialog.dart';
import 'package:vimob/ui/proposal/proposal_detail_page.dart';
import 'package:vimob/ui/proposal/remove_proposal_dialog.dart';
import 'package:vimob/ui/proposal/send_proposal_dialog.dart';
import 'package:vimob/ui/proposal/status_chip.dart';

class ProposalCard extends StatefulWidget {
  ProposalCard({
    Key key,
    this.proposal,
    this.companyStatuses,
  }) : super(key: key);

  final Proposal proposal;
  final CompanyStatuses companyStatuses;

  @override
  _ProposalCardState createState() => _ProposalCardState();
}

class _ProposalCardState extends State<ProposalCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key("card_container"),
      child: InkWell(
        onTap: () {
          //open proposal details
          _openProposalDetail(context);
        },
        onLongPress: () async {
          //open proposal options
          await showModalBottomSheet(
              context: context,
              builder: (context) {
                return _buildModalBottomSheet(context);
              });
        },
        child: Card(
          elevation: 0.1,
          child: Container(
            foregroundDecoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: widget.companyStatuses
                          ?.proposals[widget?.proposal?.status]?.color ??
                      Colors.black,
                  width: Style.horizontal(1.5),
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  right: Style.horizontal(4),
                  left: Style.horizontal(4),
                  top: Style.horizontal(2),
                  bottom: Style.horizontal(2)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: Style.horizontal(2)),
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: Style.horizontal(1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                              flex: 3,
                              child:
                                  StatusChip(status: widget.proposal.status)),
                          Expanded(flex: 4, child: _buildDateInformation())
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: Style.horizontal(0.5)),
                    child: _buildCardInformation(
                        widget.proposal.development.name,
                        icon: _buildDevelopmentIconType(),
                        textKey: Key("development_name_text")),
                  ),
                  _buildCardInformation(
                      "${I18n.of(context).block}: ${widget.proposal.block.name}",
                      textKey: Key("block_name_text")),
                  Padding(
                    padding: EdgeInsets.only(top: Style.horizontal(0.5)),
                    child: _buildCardInformation(
                        "${I18n.of(context).unit}: ${widget.proposal.unit.name}",
                        textKey: Key("unit_name_text")),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: Style.horizontal(0.5)),
                    child: _buildCardInformation(_buyerName(),
                        icon: Icon(Icons.person),
                        textKey: Key("buyer_name_text")),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _buildModalBottomSheet(BuildContext context) {
    if (widget.proposal.status == 'inAttendance' &&
        widget.proposal.idProposalMega == null) {
      return Container(
        height: Style.horizontal(47),
        padding: EdgeInsets.only(
            top: Style.horizontal(2), left: Style.horizontal(2)),
        child: Column(
          children: <Widget>[
            _buildModalProposalOption(
                componentKey: Key("open_proposal_detail_button"),
                icon: SvgPicture.asset(
                  "assets/proposals/proposals.svg",
                  color: Style.mainTheme.iconTheme.color,
                  height: Style.mainTheme.iconTheme.size,
                  key: Key("proposal_page"),
                ),
                text: I18n.of(context).proposalDetail,
                onTap: () {
                  Navigator.pop(context);
                  _openProposalDetail(context);
                }),
            _buildModalProposalOption(
                componentKey: Key("send_proposal_button"),
                icon: Icon(Icons.send),
                text: I18n.of(context).sendProposal,
                onTap: () async {
                  if (widget.proposal.buyer != null) {
                    await showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) =>
                            SendProposalDialog(proposal: widget.proposal));
                  } else {
                    await showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) =>
                            LinkBuyerDialog(proposal: widget.proposal));
                  }
                }),
            _buildModalProposalOption(
                componentKey: Key("remove_proposal_button"),
                icon: Icon(Icons.delete),
                text: I18n.of(context).remove,
                onTap: () async {
                  await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) =>
                          RemoveProposalDialog(proposal: widget.proposal));
                }),
          ],
        ),
      );
    } else {
      return Container(
        height: Style.horizontal(18),
        padding: EdgeInsets.only(
            top: Style.horizontal(1), left: Style.horizontal(2)),
        child: Column(
          children: <Widget>[
            _buildModalProposalOption(
                componentKey: Key("open_proposal_detail_button"),
                icon: SvgPicture.asset(
                  "assets/proposals/proposals.svg",
                  color: Style.mainTheme.iconTheme.color,
                  height: Style.mainTheme.iconTheme.size,
                  key: Key("proposal_page"),
                ),
                text: I18n.of(context).proposalDetail,
                onTap: () {
                  Navigator.pop(context);
                  _openProposalDetail(context);
                }),
          ],
        ),
      );
    }
  }

  void _openProposalDetail(BuildContext context) {
    var developments = Provider.of<DevelopmentState>(context, listen: false)
        .developments
        .value;

    Development development = developments.singleWhere(
        (development) => development.id == widget.proposal.development.id);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProposalDetailPage(
                  proposal: widget.proposal,
                  development: development,
                  initialIndex: 1,
                )));
  }

  Widget _buildModalProposalOption(
      {Key componentKey, Widget icon, String text, Function onTap}) {
    return Column(
      children: <Widget>[
        InkWell(
          key: componentKey,
          onTap: onTap ?? () {},
          child: Padding(
            padding: EdgeInsets.all(Style.horizontal(2)),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: Style.horizontal(4)),
                  child: icon ?? Icon(Icons.error_outline),
                ),
                Text(text ?? "No text."),
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }

  SvgPicture _buildDevelopmentIconType() {
    String iconPath = "assets/proposals/office_building.svg";
    if (widget.proposal.development.type == "land") {
      iconPath = "assets/proposals/land.svg";
    }

    return SvgPicture.asset(
      iconPath,
      height: Style.mainTheme.iconTheme.size,
      color: Style.mainTheme.iconTheme.color,
      key: Key("unit_type_icon"),
    );
  }

  Widget _buildDateInformation() {
    TextSpan idProposalMegaText = TextSpan(text: "");
    if (widget.proposal.idProposalMega != null) {
      idProposalMegaText = TextSpan(
          text: "${widget.proposal.idProposalMega.toString()}",
          style: Style.mainTheme.textTheme.bodyText2
              .copyWith(fontWeight: FontWeight.bold),
          children: <TextSpan>[
            TextSpan(
              text: " | ",
              style: Style.mainTheme.textTheme.bodyText2,
            ),
          ]);
    }

    return RichText(
      key: Key("id_date_text"),
      textAlign: TextAlign.right,
      text: TextSpan(children: <TextSpan>[
        idProposalMegaText,
        TextSpan(
            text:
                "${I18n.of(context).formatDate(date: widget.proposal.date, abbreviated: true)}",
            style: Style.mainTheme.textTheme.bodyText2)
      ]),
    );
  }

  Widget _buildCardInformation(String text, {Widget icon, Key textKey}) {
    return Padding(
      padding: EdgeInsets.only(left: Style.horizontal(2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: Style.horizontal(7),
            child: Padding(
              padding: EdgeInsets.only(right: Style.horizontal(2)),
              child: icon ??
                  Icon(
                    Icons.ac_unit,
                    color: Colors.transparent,
                  ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: Style.horizontal(2)),
              child: AutoSizeText(
                text,
                maxLines: 2,
                style: Style.mainTheme.textTheme.bodyText2,
                key: textKey,
              ),
            ),
          )
        ],
      ),
    );
  }

  String _buyerName() {
    return widget.proposal.buyer != null
        ? widget.proposal.buyer.name
        : I18n.of(context).clientNotBound;
  }
}
