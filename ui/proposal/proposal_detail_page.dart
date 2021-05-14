import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/buyer/buyer.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/states/buyer_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/clients/buyer_page.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/proposal/link_buyer_tab.dart';
import 'package:vimob/ui/proposal/proposal_detail_information_tab.dart';
import 'package:vimob/ui/proposal/proposal_detail_negotiation_tab.dart';

class ProposalDetailPage extends StatefulWidget {
  ProposalDetailPage(
      {Key key,
      @required this.proposal,
      @required this.development,
      @required this.initialIndex,
      this.backToProposalList})
      : super(key: key);

  final Proposal proposal;
  final Development development;
  final int initialIndex;
  final bool backToProposalList;

  @override
  _ProposalDetailPageState createState() => _ProposalDetailPageState();
}

class _ProposalDetailPageState extends State<ProposalDetailPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  Proposal _proposal;
  Buyer _proposalBuyer;
  Reference _buyerReference;

  String idProposalMegaText;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialIndex ?? 0);
    idProposalMegaText = widget.proposal.idProposalMega != null
        ? "nº ${widget.proposal.idProposalMega}"
        : "";
  }

  @override
  Widget build(BuildContext context) {
    _proposal = Provider.of<ProposalState>(context)
        .currentProposals
        .value
        .singleWhere((proposal) => proposal.id == widget.proposal.id);

    setState(() {
      _buyerReference = Provider.of<ProposalState>(context)
          .currentProposals
          .value
          .firstWhere((proposal) => proposal.id == widget.proposal.id)
          .buyer;

      if (_buyerReference != null) {
        _proposalBuyer = Provider.of<BuyerState>(context)
            .buyersList
            .value
            .firstWhere((item) => item.id == _buyerReference.id);
      }
    });

    return Scaffold(
      appBar: AppBarResponsive().show(
          title: "${I18n.of(context).proposal} $idProposalMegaText",
          leading: InkWell(
            key: Key("exit_development_list_page"),
            onTap: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: Icon(
              Icons.close,
              color: Style.mainTheme.appBarTheme.iconTheme.color,
            ),
          ),
          context: context,
          elevation: 0),
      body: Column(
        children: <Widget>[
          Material(
            color: Style.brandColor,
            child: SizedBox(
              height: Style.horizontal(10),
              child: TabBar(
                  labelPadding: EdgeInsets.all(0),
                  indicatorColor: Colors.white,
                  controller: _tabController,
                  tabs: <Widget>[
                    Tab(
                      key: Key("proposal_detail_information_tab"),
                      child: Text(
                        I18n.of(context).information.toUpperCase(),
                        style: Style.textProposalDetailsTitleTabs,
                      ),
                    ),
                    Tab(
                      key: Key("proposal_detail_negociation_tab"),
                      child: Text(
                        I18n.of(context).negotiation.toUpperCase(),
                        style: Style.textProposalDetailsTitleTabs,
                      ),
                    ),
                    Tab(
                      key: Key("proposal_detail_client_tab"),
                      child: Text(
                        I18n.of(context).client.toUpperCase(),
                        style: Style.textProposalDetailsTitleTabs,
                      ),
                    ),
                  ]),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                ProposalDetailInformationTab(
                  development: widget.development,
                  proposal: _proposal,
                ),
                ProposalDetailNegotiationTab(
                  proposal: _proposal,
                ),
                _buyerReference != null && _proposalBuyer != null
                    ? BuyerPage(
                        mode: BuyerAppBarMode.view,
                        buyer: _proposalBuyer,
                        proposal: widget.proposal,
                      )
                    : LinkBuyerTab(proposal: widget.proposal),
              ],
            ),
          )
        ],
      ),
    );
  }
}
