import 'package:flutter/material.dart';
import 'package:vimob/blocs/development/development_bloc.dart';
import 'package:vimob/blocs/proposal/proposal_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/payment/payment_plan_page.dart';
import 'package:vimob/ui/proposal/proposal_attachment_list.dart';
import 'package:vimob/ui/proposal/proposal_history_list.dart';
import 'package:vimob/ui/proposal/status_chip.dart';

class ProposalDetailNegotiationTab extends StatefulWidget {
  const ProposalDetailNegotiationTab({
    Key key,
    this.proposal,
  }) : super(key: key);

  final Proposal proposal;

  @override
  _ProposalDetailNegotiationTabState createState() =>
      _ProposalDetailNegotiationTabState();
}

class _ProposalDetailNegotiationTabState
    extends State<ProposalDetailNegotiationTab>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  PaymentPlan paymentPlan;
  Color _firstTabColor;
  Color _secundTabColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        setState(() {
          _firstTabColor = Colors.black12;
          _secundTabColor = Colors.white;
        });
      } else {
        setState(() {
          _firstTabColor = Colors.white;
          _secundTabColor = Colors.black12;
        });
      }
    });
    ProposalState().fetchProposalLogs(proposalId: widget.proposal.id);
    ProposalState().fetchAttachment(
        proposalId: widget.proposal.id,
        deviceWidth: (Style.horizontal(100) * Style.devicePixelRatio));
    paymentPlan =
        widget.proposal.modifiedPaymentPlan ?? widget.proposal.paymentPlan;
    _firstTabColor = Colors.black12;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Style.horizontal(4), vertical: Style.horizontal(4)),
          child: Wrap(
            runSpacing: Style.horizontal(4),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "${paymentPlan.name}",
                      key: Key("proposal_detail_negotiation_payment_plan_name"),
                    ),
                  ),
                  Expanded(
                    child: StatusChip(
                      status: widget.proposal.status,
                    ),
                  )
                ],
              ),
              Text(
                "R\$ " +
                    I18n.of(context).formatCurrency(
                        ProposalBloc().totalCalculate(paymentPlan.series)),
                key: Key("proposal_detail_negotiation_total"),
                style: Style.titleSecondaryText
                    .copyWith(fontSize: Style.horizontal(8)),
              ),
              SizedBox(
                  width: double.infinity,
                  child: OutlineButton(
                      borderSide: BorderSide(
                          width: Style.horizontal(0.3),
                          color: Style.textDefaultColor),
                      textColor: Style.textDefaultColor,
                      onPressed: () => _handleOnPressedChangeValues(),
                      child: Text(widget.proposal.status == 'inAttendance'
                          ? I18n.of(context).changeValues
                          : I18n.of(context).visualizeValues))),
            ],
          ),
        ),
        Divider(),
        TabBar(
          isScrollable: false,
          indicatorColor: Colors.transparent,
          labelPadding: EdgeInsets.symmetric(
            vertical: Style.horizontal(1),
          ),
          controller: _tabController,
          // onTap: (_index) {
          //   switch (_index) {
          //     case 0:
          //       setState(() {
          //         _firstTabColor = Colors.black12;
          //         _secundTabColor = Colors.white;
          //       });
          //       break;
          //     case 1:
          //       setState(() {
          //         _firstTabColor = Colors.white;
          //         _secundTabColor = Colors.black12;
          //       });
          //       break;
          //     default:
          //   }
          // },
          tabs: [
            Container(
              height: Style.horizontal(12),
              color: _firstTabColor,
              child: Tab(
                key: Key("negotiation_history_tab"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: Style.horizontal(2)),
                      child: Icon(
                        Icons.linear_scale,
                        color: Style.mainTheme.iconTheme.color,
                        size: Style.mainTheme.iconTheme.size,
                      ),
                    ),
                    Text(
                      I18n.of(context).history.toUpperCase(),
                      style: Style.mainTheme.textTheme.bodyText2,
                    )
                  ],
                ),
              ),
            ),
            Container(
              color: _secundTabColor,
              child: Tab(
                key: Key("negociation_attachments_tab"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: Style.horizontal(2)),
                      child: Icon(
                        Icons.attachment,
                        color: Style.mainTheme.iconTheme.color,
                        size: Style.mainTheme.iconTheme.size,
                      ),
                    ),
                    Text(
                      I18n.of(context).attachments.toUpperCase(),
                      style: Style.mainTheme.textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(controller: _tabController, children: [
            ProposalHistoryList(
              proposal: widget.proposal,
            ),
            ProposalAttachmentList(
              proposal: widget.proposal,
            ),
          ]),
        ),
      ],
    );
  }

  _handleOnPressedChangeValues() async {
    ProposalState().proposalDate = widget.proposal.date;
    ProposalState().selectedProposal = widget.proposal;

    ProposalState().selectedDevelopment = DevelopmentState()
        .developments
        .value
        .firstWhere((dev) => dev.id == widget.proposal.development.id);

    ProposalState().selectedBlock =
        await DevelopmentBloc().fetchBlock(blockId: widget.proposal.block.id);

    ProposalState().selectedUnit = widget.proposal.unit.developmentUnit;
    ProposalState().selectedPaymentPlan =
        PaymentPlan().clone(widget.proposal.paymentPlan);

    PaymentState().modifiedPaymentSeries = widget
        .proposal.modifiedPaymentPlan.series
        .map((e) => e.clone(e))
        .toList();
    PaymentState().intialModifiedPaymentSeries =
        PaymentState().modifiedPaymentSeries.map((e) => e.clone(e)).toList();

    if (widget.proposal.status == 'inAttendance') {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return PaymentPlanPage(
            accessMode: AccessMode.edit,
          );
        }),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return PaymentPlanPage(
            accessMode: AccessMode.view,
          );
        }),
      );
    }
  }
}
