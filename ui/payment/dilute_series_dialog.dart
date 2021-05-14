import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:vimob/blocs/payment/payment_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/payment/insufficient_value_dialog.dart';

class DiluteSeriesDialog extends StatefulWidget {
  DiluteSeriesDialog({Key key, this.type, this.accessMode}) : super(key: key) {
    PaymentState().availableSeriesToDilute.forEach((series) {
      this.selectedSeriesToDilute[series.id] = false;
    });
  }
  final PriceDifferenceType type;
  final AccessMode accessMode;
  final Map<int, bool> selectedSeriesToDilute = {0: false};
  @override
  _DiluteSeriesDialogState createState() => _DiluteSeriesDialogState();
}

class _DiluteSeriesDialogState extends State<DiluteSeriesDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildTitle(context),
          _buildDescription(context),
          _buildSeriesList(context),
          Divider(),
          _buildButtonBar(context),
        ],
      ),
    );
  }

  _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Style.horizontal(5),
        horizontal: Style.horizontal(5),
      ),
      child: Row(
        children: <Widget>[
          Text(
            I18n.of(context).whereToDilute,
            style: Style.mainTheme.textTheme.headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Style.horizontal(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _getSeriesDescription(),
            textAlign: TextAlign.left,
            style: Style.mainTheme.textTheme.bodyText2,
          ),
          Text(
            I18n.of(context).diluteText2,
            style: Style.mainTheme.textTheme.bodyText2,
          ),
        ],
      ),
    );
  }

  String _getSeriesDescription() {
    final _priceDifferenceController = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      initialValue: PaymentBloc().seriesPriceDifference(widget.type),
      thousandSeparator: '.',
      decimalSeparator: ',',
    );

    Map<String, String> text = {
      '[name]': PaymentState().selectedSeries.text,
      '[value]': _priceDifferenceController.text,
    };

    return I18n.of(context).interpolateText(
      I18n.of(context).diluteText1,
      text,
    );
  }

  Widget _buildSeriesList(BuildContext context) {
    return Flexible(
      child: ListView(
        shrinkWrap: true,
        children: PaymentState()
            .availableSeriesToDilute
            .map((series) => _buildSeriesListRow(series))
            .toList(),
      ),
    );
  }

  Widget _buildSeriesListRow(PaymentSeries series) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Style.horizontal(5)),
      child: SizedBox(
        height: Style.vertical(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              series.text,
              style: Style.subtitleText,
            ),
            Transform.scale(
              scale: .9,
              child: new Switch(
                value: widget.selectedSeriesToDilute[series.id],
                onChanged: (value) {
                  _handleOnChangedSwitch(value, series);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  _handleOnChangedSwitch(bool selected, PaymentSeries series) {
    PaymentBloc().setSelectedSeriesToDilute(selected, series);

    setState(() {
      widget.selectedSeriesToDilute[series.id] = selected;
    });
  }

  Widget _buildButtonBar(BuildContext context) {
    return Row(
      children: <Widget>[
        _buildButton(
          context,
          I18n.of(context).cancel,
          () => _handleOnTapCancel(context),
        ),
        _buildButton(
          context,
          I18n.of(context).save,
          () => _handleOnTapConfirm(context),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String text, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: Style.horizontal(10),
        width: Style.horizontal(40),
        child: Center(
          child: Text(
            text,
            style: Style.mainTheme.textTheme.button.copyWith(
              color: Style.textButtonColorLink,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  _handleOnTapCancel(BuildContext context) {
    PaymentBloc().resetSelectedSeriesToDilute();
    Navigator.pop(context);
  }

  _handleOnTapConfirm(BuildContext context) {
    if (PaymentBloc().diluteSeries(widget.type)) {
      widget.type == PriceDifferenceType.save
          ? PaymentBloc().saveSeries(widget.accessMode)
          : PaymentBloc().removeSeries();

      PaymentBloc().resetSelectedSeriesToDilute();
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 2);
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => InsufficientValueDialog(),
      );
    }
  }
}
