import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:vimob/blocs/payment/series_calc_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/common/expansion_tile.dart';
import 'package:vimob/ui/payment/payment_plan_page.dart';
import 'package:vimob/utils/animation/widget_animation.dart';

class SelectPaymentPlanPage extends StatelessWidget {
  const SelectPaymentPlanPage({
    Key key,
    @required this.paymentState,
  }) : super(key: key);

  final PaymentState paymentState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarResponsive().show(
        context: context,
        title: I18n.of(context).newProposal,
        leading: InkWell(
          key: Key("exit_select_payment_plan_page_button"),
          onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: Icon(
            Icons.close,
            color: Style.mainTheme.appBarTheme.iconTheme.color,
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return WidgetAnimation(
      child: Container(
        height: Style.vertical(100),
        color: Colors.black.withAlpha(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSubtitle(context),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: StreamBuilder<List<PaymentPlan>>(
          stream: paymentState.paymentPlans,
          builder: (context, paymentPlan) {
            if (paymentPlan.hasData) {
              return _buildExpandable(context, paymentPlan.data);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Style.horizontal(3)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Center(
                child: Text(I18n.of(context).paymentPlans,
                    style: Style.fadedTitleText),
              ),
            ),
            Spacer()
          ],
        ),
      ),
    );
  }

  Widget _buildExpandable(BuildContext context, List<PaymentPlan> paymentPlan) {
    paymentPlan
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: paymentPlan.map<Widget>(
            (PaymentPlan plan) {
              return _buildExpandableItem(context, plan);
            },
          ).toList(),
        )
      ],
    );
  }

  Widget _buildExpandableItem(BuildContext context, PaymentPlan plan) {
    List<Widget> series = [];

    plan.series.forEach((s) => series.add(_buildSeriesRow(s)));
    series.add(_buildSeriesTotal(plan));
    series.add(_buildSelectButton(context, plan));

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 0.25, color: Style.textFadedColor),
          left: BorderSide(width: 0.25, color: Style.textFadedColor),
          right: BorderSide(width: 0.25, color: Style.textFadedColor),
          bottom: BorderSide(width: 0.25, color: Style.textFadedColor),
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: Style.vertical(1),
          bottom: Style.vertical(1),
          left: Style.vertical(2),
          right: Style.vertical(2),
        ),
        child: ExpansionTileCustom(
            title: Text(
              plan.name,
              style: Style.mainTheme.textTheme.headline6,
            ),
            subtitle: Text(
              '${I18n.of(context).paymentPlanExpiry} '
              '${I18n.of(context).formatDate(date: Jiffy(plan.end), abbreviated: true)}',
              style: Style.subtitleText,
            ),
            children: series),
      ),
    );
  }

  Widget _buildSeriesRow(PaymentSeries series) {
    final numberOfPayments = series.numberOfPayments;

    final seriesValue = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      initialValue: series.prices.nominal.seriesValue,
      thousandSeparator: '.',
      decimalSeparator: ',',
    );

    final seriesTotal = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      initialValue: series.prices.nominal.seriesTotal,
      thousandSeparator: '.',
      decimalSeparator: ',',
    );

    final seriesPrice =
        "$numberOfPayments x ${seriesValue.text} = ${seriesTotal.text}";

    return _buildSeries(series.text, seriesPrice, Icons.attach_money);
  }

  Widget _buildSeriesTotal(PaymentPlan plan) {
    double total = SeriesCalcBloc().getUnitPrice(
      ProposalState().selectedUnit.price,
      plan,
    );

    final seriesValue = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      initialValue: total,
      thousandSeparator: '.',
      decimalSeparator: ',',
    );

    return _buildSeries("Total", seriesValue.text, Icons.store);
  }

  Widget _buildSeries(String name, String price, IconData icon) {
    return ListTile(
      title: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Style.horizontal(2),
              vertical: Style.horizontal(2),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 25,
                  child: Icon(
                    icon,
                    size: 25,
                    color: Style.textDefaultColor,
                  ),
                ),
                Text(
                  "$name",
                  style: Style.mainTheme.textTheme.headline6,
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Style.horizontal(2)),
            child: Row(
              children: <Widget>[
                Container(width: 25),
                Text(
                  price,
                  style: Style.paymentSeriesText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectButton(BuildContext context, PaymentPlan plan) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Style.horizontal(10),
          vertical: Style.horizontal(5),
        ),
        child: OutlineButton(
          borderSide: BorderSide(
              width: Style.horizontal(0.3), color: Style.textDefaultColor),
          textColor: Style.textDefaultColor,
          onPressed: () => _handlePaymentPlanPageNavigation(context, plan),
          child: Text(I18n.of(context).selectPaymentPlan),
        ),
      ),
    );
  }

  _handlePaymentPlanPageNavigation(BuildContext context, PaymentPlan plan) {
    ProposalState().selectedProposal = Proposal();
    ProposalState().selectedProposal.date = Jiffy();
    ProposalState().selectedPaymentPlan = PaymentPlan().clone(plan);
    PaymentState().modifiedPaymentSeries =
        plan.series.map((series) => PaymentSeries().clone(series)).toList();
    PaymentState().intialModifiedPaymentSeries =
        plan.series.map((series) => PaymentSeries().clone(series)).toList();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return PaymentPlanPage(
          accessMode: AccessMode.create,
        );
      }),
    );
  }
}
