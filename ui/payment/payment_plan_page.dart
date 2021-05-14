import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/payment/payment_bloc.dart';
import 'package:vimob/blocs/proposal/proposal_bloc.dart';
import 'package:vimob/blocs/payment/series_calc_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/common/fab_menu.dart';
import 'package:vimob/ui/payment/invalid_payment_plan_dialog.dart';
import 'package:vimob/ui/payment/proposal_saved_page.dart';
import 'package:vimob/ui/payment/view_series.dart';
import 'package:vimob/ui/payment/remove_series_dialog.dart';
import 'package:vimob/utils/animation/widget_animation.dart';

class PaymentPlanPage extends StatefulWidget {
  PaymentPlanPage({
    Key key,
    @required this.accessMode,
    this.proposal,
  }) : super(key: key);

  final AccessMode accessMode;
  final Proposal proposal;

  @override
  _PaymentPlanPageState createState() => _PaymentPlanPageState();
}

class _PaymentPlanPageState extends State<PaymentPlanPage> {
  final int nominal = 0;
  final int future = 1;
  bool _isEnabled = true;
  Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;

  final List<bool> selectedPriceType = [
    true, // nominal
    false, // future
  ]; // defaults to nominal

  @override
  Widget build(BuildContext context) {
    Provider.of<PaymentState>(context);

    var _wasModified = !unOrdDeepEq(PaymentState().modifiedPaymentSeries,
        PaymentState().intialModifiedPaymentSeries);
    return Scaffold(
      appBar: AppBarResponsive().show(
          context: context,
          title: widget.accessMode == AccessMode.create
              ? I18n.of(context).newProposal
              : I18n.of(context).series,
          leading: InkWell(
            key: Key("exit_payment_plan_page_button"),
            onTap: () async {
              if (widget.accessMode == AccessMode.edit && _wasModified) {
                await _buildShowDialog(context);
              } else {
                Navigator.pop(context);
              }
            },
            child: Icon(
              Icons.close,
              color: Style.mainTheme.appBarTheme.iconTheme.color,
            ),
          ),
          actions: widget.accessMode == AccessMode.edit
              ? <Widget>[
                  InkWell(
                    onTap: () async =>
                        _wasModified ? await _handleSaveProposal() : null,
                    child: Icon(
                      Icons.check,
                      color: _wasModified
                          ? Style.mainTheme.appBarTheme.actionsIconTheme.color
                          : Style.disableTextColor,
                    ),
                  )
                ]
              : null),
      floatingActionButton:
          widget.accessMode == AccessMode.view ? null : _buildFabMenu(),
      body: _buildBody(),
    );
  }

  Future _buildShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
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
                          I18n.of(context).warning,
                          style: Style.mainTheme.textTheme.headline6
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(I18n.of(context).saveWarning),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: Style.horizontal(4)),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Text(I18n.of(context).cancel,
                                style: Style.mainTheme.textTheme.button
                                    .copyWith(
                                        color: Style.textButtonColorLink,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              PaymentState().modifiedPaymentSeries =
                                  PaymentState()
                                      .intialModifiedPaymentSeries
                                      .map((e) => e)
                                      .toList();

                              int count = 0;
                              Navigator.of(context)
                                  .popUntil((_) => count++ >= 2);
                            },
                            child: Text(
                              I18n.of(context).exit,
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
              ],
            ),
          )),
    );
  }

  Widget _buildBody() {
    return WidgetAnimation(
      child: Container(
        height: Style.vertical(100),
        color: Colors.black.withAlpha(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.accessMode == AccessMode.create
                ? _buildSubtitle(context)
                : Container(),
            _buildHeader(context),
            _buildSeriesList(context),
            _buildBottom(context)
          ],
        ),
      ),
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
                child: Text(
                  ProposalState().selectedPaymentPlan.name,
                  style: Style.fadedTitleText,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: Style.horizontal(5)),
              child: GestureDetector(
                onTap: () async => _handleSaveProposal(),
                child: Text(
                  I18n.of(context).save.toUpperCase(),
                  style: TextStyle(
                    color: Style.textOrangeColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _handleSaveProposal() async {
    if (_isEnabled) {
      setState(() {
        _isEnabled = false;
      });
      List<String> errorMessages = PaymentBloc().validatePaymentPlan(context);

      if (errorMessages.length == 0) {
        await ProposalBloc().addNewProposal();

        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return ProposalSavedPage();
          }),
        );
      } else {
        setState(() {
          _isEnabled = true;
        });
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) =>
              InvalidPaymentPlanDialog(errorMessages: errorMessages),
        );
      }
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Container(
        height: Style.horizontal(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildHeaderTitle(),
            _buildHeaderButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return Expanded(
      flex: 4,
      child: Center(
        child: Text(
          I18n.of(context).nominalFuture,
          style: TextStyle(
            color: Style.textFadedColor,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButtons() {
    return Expanded(
      flex: 7,
      child: Center(
        child: Row(
          children: <Widget>[
            ToggleButtons(
              selectedColor: Style.textFadedColor,
              highlightColor: Style.textFadedColorTransparent,
              fillColor: Style.textFadedColorTransparent,
              splashColor: Style.textFadedColorTransparent,
              children: <Widget>[
                _buildToggleButton(I18n.of(context).nominal),
                _buildToggleButton(I18n.of(context).future),
              ],
              onPressed: _handleOnPressedNominalFuture,
              isSelected: selectedPriceType,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text) {
    return Container(
      width: Style.horizontal(30),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(text.toUpperCase(), style: Style.nominalFutureText),
        ),
      ),
    );
  }

  _handleOnPressedNominalFuture(int index) {
    setState(() {
      for (int buttonIndex = 0;
          buttonIndex < selectedPriceType.length;
          buttonIndex++) {
        if (buttonIndex == index) {
          selectedPriceType[buttonIndex] = true;
        } else {
          selectedPriceType[buttonIndex] = false;
        }
      }
    });
  }

  Widget _buildSeriesList(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: PaymentState()
                .modifiedPaymentSeries
                .map<Widget>((series) => _buildSeriesRow(context, series))
                .toList(),
          )
        ],
      ),
    );
  }

  //refactor
  Widget _buildSeriesRow(BuildContext context, PaymentSeries series) {
    return InkWell(
      onTap: () => _handleOnTap(
          series,
          widget.accessMode == AccessMode.view
              ? AccessMode.view
              : AccessMode.edit),
      onLongPress: () => widget.accessMode != AccessMode.view
          ? _handleBottomSheet(context, series)
          : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(width: 0.25, color: Style.textFadedColor)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Style.horizontal(4),
            vertical: Style.horizontal(3.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildSeriesRowPrice(
                series.text,
                series.prices,
                series.numberOfPayments,
              ),
              _buildSeriesRowDate(series.dueDate.date),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesRowPrice(
    String name,
    PaymentSeriesPrices prices,
    int numberOfPayments,
  ) {
    double seriesValue = selectedPriceType.indexOf(true) == nominal
        ? prices.nominal.seriesValue
        : prices.future.seriesValue;

    MoneyMaskedTextController value = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      initialValue: seriesValue,
      thousandSeparator: '.',
      decimalSeparator: ',',
    );

    double seriesTotal = prices.nominal.seriesTotal;

    MoneyMaskedTextController total = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      initialValue: seriesTotal,
      thousandSeparator: '.',
      decimalSeparator: ',',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          name,
          style: Style.paymentSeriesText,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            "${numberOfPayments}x ${value.text}",
            style: Style.titleSecondaryText,
          ),
        ),
        Text(
          "= ${total.text}",
          style: Style.mainTheme.textTheme.headline6,
        ),
      ],
    );
  }

  Widget _buildSeriesRowDate(Jiffy date) {
    return Column(
      children: <Widget>[
        Text(
          I18n.of(context).formatDatePaymentPlan(date: date),
          style: Style.paymentSeriesText,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            Jiffy(date).format("d"),
            style: TextStyle(
              color: Style.textDefaultColor,
              fontSize: 22,
            ),
          ),
        ),
      ],
    );
  }

  _handleOnTap(PaymentSeries series, AccessMode accessMode) async {
    _selectSeries(series);

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ViewSeriesPage(accessMode: accessMode);
      }),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Style.brandColor),
      height: 100,
      //height: Style.vertical(10.5),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildBottomTotal(),
            _buildBottomProposalPrice(),
            _buildBottomUnitPrice(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTotal() {
    return Text(
      I18n.of(context).total.toUpperCase(),
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    );
  }

  Widget _buildBottomProposalPrice() {
    double total = SeriesCalcBloc().getPaymentPlanTotalPrice(
      PaymentState().modifiedPaymentSeries,
    );

    MoneyMaskedTextController proposalTotal = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      initialValue: total,
      thousandSeparator: '.',
      decimalSeparator: ',',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          SvgPicture.asset(
            "assets/proposals/proposals.svg",
            color: Style.unselectedOptions,
            height: Style.mainTheme.iconTheme.size,
            key: Key("proposal_page"),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              proposalTotal.text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomUnitPrice() {
    MoneyMaskedTextController unitPrice = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      initialValue: SeriesCalcBloc().getUnitPrice(
        ProposalState().selectedUnit.price,
        ProposalState().selectedPaymentPlan,
      ),
      thousandSeparator: '.',
      decimalSeparator: ',',
    );

    return Row(
      children: <Widget>[
        SvgPicture.asset(
          "assets/proposals/office_building.svg",
          color: Style.unselectedOptions,
          height: Style.mainTheme.iconTheme.size,
          key: Key("proposal_page"),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            unitPrice.text,
            style: TextStyle(
              color: Style.unselectedOptions,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  FABMenu _buildFabMenu() {
    return FABMenu(
      componentKey: Key("fab_menu"),
      mainIcon: Icons.add,
      yOffset: Style.vertical(7.5),
      xOffset: Style.horizontal(2),
      options: <FABMenuOptionProperties>[
        FABMenuOptionProperties(
          onTapKey: Key("fab_menu_payment_plan"),
          onTap: () async {
            _selectSeries(PaymentBloc()
                .newSeries(ProposalState().selectedPaymentPlan.series[0]));

            PaymentState().selectedSeries.isNew = true;
            PaymentState().modifiedSelectedSeries.isNew = true;

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewSeriesPage(
                  accessMode: AccessMode.create,
                ),
              ),
            );
          },
          icon: Icon(
            Icons.date_range,
            color: Colors.black,
          ),
          text: Text(
            'Série',
            style: Style.mainTheme.textTheme.bodyText2,
          ),
        ),
      ],
    );
  }

  _handleBottomSheet(BuildContext context, PaymentSeries series) {
    _selectSeries(series);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: Style.horizontal(30),
          padding: EdgeInsets.only(
            top: Style.horizontal(2),
            left: Style.horizontal(2),
          ),
          child: Column(
            children: <Widget>[
              _buildEditOption(),
              _buildDeleteOption(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditOption() {
    return _buildModalOption(
      componentKey: Key("open_edit_series_button"),
      icon: Icon(Icons.edit),
      text: I18n.of(context).editSeries,
      onTap: () async {
        Navigator.of(context).pop(); // Closes the BottomSheet
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewSeriesPage(
              accessMode: AccessMode.edit,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteOption() {
    return _buildModalOption(
        componentKey: Key("delete_series_button"),
        icon: Icon(Icons.delete),
        text: I18n.of(context).deleteSeries,
        onTap: () async {
          PaymentBloc().setAvailableSeriesToDilute();

          await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => RemoveSeriesDialog(),
          );
        });
  }

  Widget _buildModalOption(
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

  _selectSeries(PaymentSeries series) {
    PaymentState().selectedSeries = series;
    PaymentState().modifiedSelectedSeries = PaymentSeries().clone(series);
  }
}
