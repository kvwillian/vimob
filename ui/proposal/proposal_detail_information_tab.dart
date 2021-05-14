import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vimob/blocs/proposal/proposal_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/style.dart';

class ProposalDetailInformationTab extends StatefulWidget {
  ProposalDetailInformationTab({
    Key key,
    this.development,
    this.proposal,
  }) : super(key: key);

  final Development development;
  final Proposal proposal;

  @override
  _ProposalDetailInformationTabState createState() =>
      _ProposalDetailInformationTabState();
}

class _ProposalDetailInformationTabState
    extends State<ProposalDetailInformationTab> {
  PaymentPlan paymentPlan;

  @override
  void initState() {
    super.initState();
    paymentPlan =
        widget.proposal.modifiedPaymentPlan ?? widget.proposal.paymentPlan;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Style.horizontal(100),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: Style.horizontal(4)),
            child: Column(
              children: <Widget>[
                _buildDevelopmentInfo(context),
                Divider(),
                _buildUnitInfo(context),
                Divider(),
                _buildPaymentInfo(context),
                Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Style.horizontal(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCircularAvatar(text: "3"),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(I18n.of(context).paymentConditions.toUpperCase()),
              Text(
                "${paymentPlan.name}",
                style: Style.titleSecondaryText,
                key: Key("proposal_detail_information_payment_plan_name_text"),
              ),
              ..._buildPaymentSeries(context),
              _buildTotalValue(context),
            ],
          )
        ],
      ),
    );
  }

  Padding _buildTotalValue(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Style.horizontal(2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: Style.horizontal(2)),
            child: Icon(Icons.date_range),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Total",
                  style: Style.mainTheme.textTheme.bodyText2
                      .copyWith(fontWeight: FontWeight.bold)),
              Text(
                "R\$ " +
                    I18n.of(context).formatCurrency(
                        ProposalBloc().totalCalculate(paymentPlan.series)),
                key: Key("total_serie_value"),
              )
            ],
          ),
        ],
      ),
    );
  }

  Padding _buildUnitInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Style.horizontal(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCircularAvatar(text: "2"),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.proposal.development.type == "unit"
                    ? I18n.of(context).unit.toUpperCase()
                    : I18n.of(context).land),
                Text(
                  "${widget.proposal.unit.developmentUnit.block.name} - ${widget.proposal.unit.name}",
                  style: Style.titleSecondaryText,
                ),
                Padding(
                  padding: EdgeInsets.only(top: Style.horizontal(4)),
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: Style.horizontal(1),
                    children: <Widget>[
                      widget.proposal.unit.developmentUnit.room != null &&
                              widget.proposal.development.type == "unit"
                          ? _buildUnitInformation(
                              key: "proposal_detail_information_rooms_text",
                              text: "${I18n.of(context).rooms}: ",
                              data:
                                  "${widget.proposal.unit.developmentUnit.room}",
                              icon: Icon(Icons.hotel))
                          : Container(),
                      widget.proposal.unit.developmentUnit.area
                                  .privateSquareMeters !=
                              null
                          ? _buildUnitInformation(
                              key: "proposal_detail_information_metric_text",
                              text: "${I18n.of(context).metrics}: ",
                              data:
                                  "${widget.proposal.unit.developmentUnit.area.privateSquareMeters.toStringAsFixed(2)}m²",
                              icon: Icon(Icons.zoom_out_map))
                          : Container(),
                      widget.proposal.unit.developmentUnit.typology != null
                          ? _buildUnitInformation(
                              key: "proposal_detail_information_typology_text",
                              text: "${I18n.of(context).typology}: ",
                              data:
                                  "${widget.proposal.unit.developmentUnit.typology}",
                              icon: Icon(Icons.assignment))
                          : Container(),
                      widget.proposal.unit.developmentUnit.type != null
                          ? _buildUnitInformation(
                              key: "proposal_detail_information_type_text",
                              text: "${I18n.of(context).type}: ",
                              data:
                                  " ${widget.proposal.unit.developmentUnit.type}",
                              icon: Icon(Icons.map))
                          : Container(),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDevelopmentInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildCircularAvatar(text: "1"),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(I18n.of(context).development.toUpperCase()),
              Text(
                "${widget.proposal.development.name}",
                style: Style.titleSecondaryText,
                key: Key("proposal_detail_information_development_name"),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: Style.horizontal(2), bottom: Style.horizontal(4)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.location_on),
                    Expanded(
                      child: Text(
                        "${widget.development.address.streetAddress}, ${widget.development.address.number} - ${widget.development.address.neighborhood} - ${widget.development.address.city} - ${widget.development.address.state} - ${widget.development.address.zipCode}",
                        softWrap: true,
                        key: Key("proposal_detail_information_address"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildUnitInformation(
      {String text, Icon icon, String data, String key}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: Style.horizontal(2)),
          child: icon ??
              Icon(
                Icons.error,
              ),
        ),
        Text(
          text ?? "error",
          style: Style.mainTheme.textTheme.bodyText2
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          data ?? "error",
          key: Key(key),
        ),
      ],
    );
  }

  Padding _buildCircularAvatar({String text}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Style.horizontal(4)),
      child: CircleAvatar(
        radius: Style.horizontal(6),
        child: Center(
          child: Text(
            text,
            style: Style.mainTheme.textTheme.bodyText1,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPaymentSeries(BuildContext context) {
    return paymentPlan.series.map((series) {
      Icon icon = Icon(Icons.date_range);
      String text;

      switch (series.type) {
        case SeriesTypes.upfront:
          icon = Icon(Icons.attach_money);
          text = I18n.of(context).upfront;
          break;
        case SeriesTypes.monthly:
          icon = Icon(Icons.date_range);
          text = I18n.of(context).monthly;

          break;
        case SeriesTypes.yearly:
          icon = Icon(Icons.calendar_today);
          text = I18n.of(context).yearly;

          break;
        case SeriesTypes.delivery:
          icon = Icon(FontAwesomeIcons.key);
          text = I18n.of(context).delivery;

          break;
        case SeriesTypes.act:
          text = I18n.of(context).act;

          break;
        case SeriesTypes.bimonthly:
          text = I18n.of(context).bimonthly;

          break;
        case SeriesTypes.eightMonthly:
          text = I18n.of(context).eightMonthly;

          break;
        case SeriesTypes.elevenMonthly:
          text = I18n.of(context).elevenMonthly;

          break;
        case SeriesTypes.fgts:
          text = I18n.of(context).fgts;

          break;
        case SeriesTypes.financing:
          text = I18n.of(context).financing;

          break;
        case SeriesTypes.fiveMonthly:
          text = I18n.of(context).fiveMonthly;

          break;
        case SeriesTypes.nineMonthly:
          text = I18n.of(context).nineMonthly;

          break;
        case SeriesTypes.periodically:
          text = I18n.of(context).periodically;

          break;
        case SeriesTypes.quarterly:
          text = I18n.of(context).quarterly;

          break;
        case SeriesTypes.semester:
          text = I18n.of(context).semester;

          break;
        case SeriesTypes.sevenMonthly:
          text = I18n.of(context).sevenMonthly;

          break;
        case SeriesTypes.subsidy:
          text = I18n.of(context).subsidy;

          break;
        case SeriesTypes.tenMonthly:
          text = I18n.of(context).tenMonthly;

          break;
        case SeriesTypes.trimester:
          text = I18n.of(context).trimester;

          break;
        case SeriesTypes.unic:
          text = I18n.of(context).unic;

          break;
        case SeriesTypes.without:
          text = I18n.of(context).without;

          break;
        default:
          icon = Icon(Icons.date_range);
          text = "-";
      }

      return Padding(
        padding: EdgeInsets.symmetric(vertical: Style.horizontal(2)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: Style.horizontal(2)),
              child: icon,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(text,
                    style: Style.mainTheme.textTheme.bodyText2
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(
                  "${series.numberOfPayments}x R\$ ${I18n.of(context).formatCurrency(series.prices.nominal.seriesValue)} = R\$ ${I18n.of(context).formatCurrency(series.prices.nominal.seriesTotal)}",
                  key: Key("proposal_detail_information_${text}_text"),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}
