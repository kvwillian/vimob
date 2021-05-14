import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:jiffy/jiffy.dart';
import 'package:vimob/blocs/payment/series_calc_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/blocs/payment/payment_bloc.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/text_field_custom.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/ui/payment/dilute_series_dialog.dart';
import 'package:vimob/ui/payment/invalid_fields_dialog.dart';
import 'package:vimob/ui/payment/remove_series_dialog.dart';

class ViewSeriesPage extends StatefulWidget {
  ViewSeriesPage({
    Key key,
    @required this.accessMode,
  }) : super(key: key);

  final AccessMode accessMode;

  @override
  _ViewSeriesPageState createState() => _ViewSeriesPageState();
}

class _ViewSeriesPageState extends State<ViewSeriesPage> {
  String _dropdownValue;
  FieldStatus _firstDueDateController = FieldStatus();
  FieldStatus _numberOfPaymentsController = FieldStatus();
  FieldStatusMoneyMasked _nominalPriceController = FieldStatusMoneyMasked();
  FieldStatusMoneyMasked _futurePriceController = FieldStatusMoneyMasked();
  FieldStatusMoneyMasked _totalPriceController = FieldStatusMoneyMasked();
  bool isEnabled;
  @override
  void initState() {
    super.initState();
    isEnabled = widget.accessMode != AccessMode.view;

    initializeFields();
  }

  @override
  void didChangeDependencies() {
    initializeFields();
    super.didChangeDependencies();
  }

  void initializeFields() {
    _firstDueDateController.controller = TextEditingController(
      text: PaymentState()
              .modifiedSelectedSeries
              ?.dueDate
              ?.date
              ?.format('dd/MM/yyyy') ??
          ProposalState().proposalDate.format('dd/MM/yyyy'),
    );

    _numberOfPaymentsController.controller = TextEditingController(
      text: PaymentState().modifiedSelectedSeries.numberOfPayments.toString() ??
          '1',
    );

    _nominalPriceController.controller = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      initialValue:
          PaymentState().modifiedSelectedSeries.prices.nominal.seriesValue,
      thousandSeparator: '.',
      decimalSeparator: ',',
    );

    _futurePriceController.controller = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      initialValue:
          PaymentState().modifiedSelectedSeries.prices.future.seriesValue,
      thousandSeparator: '.',
      decimalSeparator: ',',
    );

    _totalPriceController.controller = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      initialValue:
          PaymentState().modifiedSelectedSeries.prices.nominal.seriesTotal,
      thousandSeparator: '.',
      decimalSeparator: ',',
    );

    PaymentBloc().setAvailableSeriesToDilute();
  }

  bool validateFields() {
    _numberOfPaymentsController = PaymentBloc().validateNumberOfPayments(
      context,
      _numberOfPaymentsController,
      widget.accessMode == AccessMode.edit,
    );

    _firstDueDateController = PaymentBloc().validateFirstDueDate(
      context,
      _firstDueDateController,
      Jiffy(_firstDueDateController.controller.text, 'dd/MM/yyyy'),
    );

    _nominalPriceController = PaymentBloc().validateSeriesNominalPrice(
      context,
      _nominalPriceController,
    );

    _futurePriceController = PaymentBloc().validateSeriesPrice(
      context,
      _futurePriceController,
    );

    _totalPriceController = PaymentBloc().validateSeriesPrice(
      context,
      _totalPriceController,
    );

    if (!_numberOfPaymentsController.isValid ||
        !_firstDueDateController.isValid ||
        !_nominalPriceController.isValid ||
        !_futurePriceController.isValid ||
        !_totalPriceController.isValid) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarResponsive().show(
        context: context,
        title: widget.accessMode == AccessMode.create
            ? I18n.of(context).insertSerie
            : I18n.of(context).editSeries,
        leading: InkWell(
          key: Key('exit_view_series_page_button'),
          onTap: () => _handleCancel(context),
          child: Icon(
            Icons.close,
            color: Style.mainTheme.appBarTheme.iconTheme.color,
          ),
        ),
        actions:
            widget.accessMode == AccessMode.view ? null : _buildActionBar(),
      ),
      body: _buildSeriesDetails(),
    );
  }

  _handleCancel(BuildContext context) {
    PaymentState().modifiedSelectedSeries =
        PaymentSeries().clone(PaymentState().selectedSeries);

    Navigator.of(context).pop();
  }

  List<Widget> _buildActionBar() {
    return <Widget>[
      widget.accessMode == AccessMode.edit
          ? _buildAction(Icons.delete, _handleRemove)
          : Container(),
      _buildAction(Icons.check, _handleSave),
    ];
  }

  _handleRemove() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => RemoveSeriesDialog(),
    );
  }

  _handleSave() async {
    if (validateFields()) {
      if (PaymentBloc().isPossibleToDilute()) {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => DiluteSeriesDialog(
            type: PriceDifferenceType.save,
            accessMode: widget.accessMode,
          ),
        );
      } else {
        PaymentState().modifiedSelectedSeries.isModified = true;
        PaymentBloc().saveSeries(widget.accessMode);
        Navigator.pop(context);
      }
    } else {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => InvalidFieldsDialog(),
      );
    }
  }

  Widget _buildAction(IconData icon, Function action) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Style.horizontal(2)),
      child: InkWell(
        onTap: action,
        child: Icon(
          icon,
          color: Style.mainTheme.appBarTheme.iconTheme.color,
          size: Style.mainTheme.appBarTheme.iconTheme.size,
        ),
      ),
    );
  }

  Widget _buildSeriesDetails() {
    return ListView(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            widget.accessMode == AccessMode.view
                ? Padding(
                    padding: EdgeInsets.only(top: Style.horizontal(8)),
                    child: Center(child: Text(I18n.of(context).viewOnly)),
                  )
                : Container(),
            _buildSeriesDropDown(),
            _buildSeriesDueDate(isEnabled),
            _buildSeriesNumberOfPayments(isEnabled),
            _buildSeriesNominalPrice(isEnabled),
            _buildSeriesFuturePrice(isEnabled),
            _buildSeriesTotalPrice(isEnabled),
          ],
        ),
      ],
    );
  }

  Widget _buildSeriesDropDown() {
    return Padding(
      padding: Style.iconPadding,
      child: Row(
        children: <Widget>[
          Padding(
            padding: Style.contentPadding,
            child: Icon(
              Icons.timer,
              size: Style.iconSize,
            ),
          ),
          Expanded(
            child: widget.accessMode == AccessMode.create
                ? _buildSeriesSelection()
                : _buildSeriesName(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesSelection() {
    List<String> paymentSeries = ProposalState()
        .selectedPaymentPlan
        .series
        .map((e) => e.text)
        .toSet()
        .toList();

    List<DropdownMenuItem<String>> _dropdownValues;

    if (paymentSeries != null) {
      _dropdownValues = paymentSeries.map<DropdownMenuItem<String>>((series) {
        return DropdownMenuItem<String>(
          value: series,
          child: Text(
            series,
            style: Style.mainTheme.textTheme.bodyText2,
          ),
        );
      }).toList();
    } else {
      _dropdownValues = [
        DropdownMenuItem<String>(value: '', child: Text('')),
        DropdownMenuItem<String>(value: '0', child: Text('Series')),
      ];
    }

    if (_dropdownValue == null || _dropdownValue == '') {
      _dropdownValue = PaymentState().modifiedSelectedSeries.text;
    }

    PaymentState().modifiedSelectedSeries.numberOfPayments = 1;
    PaymentState().modifiedSelectedSeries.prices.nominal.seriesValue = 1;
    PaymentState().modifiedSelectedSeries.prices.nominal.seriesTotal = 1;
    PaymentState().modifiedSelectedSeries.prices.future.seriesValue = 1;

    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(contentPadding: EdgeInsets.all(0)),
        value: _dropdownValue,
        items: _dropdownValues,
        onChanged: _handleDropDownOnChanged,
      ),
    );
  }

  _handleDropDownOnChanged(String newValue) {
    bool isNew = PaymentState().selectedSeries.isNew;

    PaymentSeries selectedSeries = ProposalState()
        .selectedPaymentPlan
        .series
        .firstWhere((series) => series.text == newValue);

    if (PaymentState().modifiedSelectedSeries.prices.nominal.seriesValue == 1) {
      selectedSeries = PaymentBloc().newSeries(selectedSeries);
    }
    selectedSeries.id = PaymentState().modifiedSelectedSeries.id;

    PaymentState().selectedSeries = selectedSeries;
    PaymentState().selectedSeries.isNew = isNew;
    PaymentState().modifiedSelectedSeries =
        PaymentSeries().clone(selectedSeries);
    PaymentState().modifiedSelectedSeries.isNew = isNew;

    // initializeFields();
    validateFields();

    setState(() {
      _dropdownValue = newValue;
    });
  }

  Widget _buildSeriesName() {
    TextEditingController _seriesName = TextEditingController(
      text: PaymentState().modifiedSelectedSeries.text,
    );

    return TextFieldCustom(
      componentKey: Key('view_series_series_name_field'),
      controller: _seriesName,
      label: I18n.of(context).type,
      isEnabled: false,
    );
  }

  Widget _buildSeriesDueDate(bool isEnabled) {
    return Padding(
      padding: Style.iconPadding,
      child: Row(
        children: <Widget>[
          Padding(
            padding: Style.contentPadding,
            child: Icon(
              Icons.date_range,
              size: Style.iconSize,
            ),
          ),
          Expanded(
            child: TextFieldCustom(
              componentKey: Key('view_series_first_due_date_field'),
              controller: _firstDueDateController.controller,
              label: I18n.of(context).firstDueDate,
              textInputType: TextInputType.number,
              errorText: _firstDueDateController.errorText,
              fieldIsValid: _firstDueDateController.isValid,
              readOnly: true,
              onTap: _handleFirstDueDateOnTap,
              isEnabled: isEnabled,
            ),
          ),
        ],
      ),
    );
  }

  _handleFirstDueDateOnTap() async {
    DateTime newDate = await showDatePicker(
      context: context,
      initialDate: Jiffy(
        _firstDueDateController.controller.text,
        "dd/MM/yyyy",
      ).dateTime,
      firstDate: Jiffy().subtract(years: 100),
      lastDate: Jiffy().add(years: 100),
    );

    if (newDate != null) {
      _firstDueDateController.controller.value = _firstDueDateController
          .controller.value
          .copyWith(text: Jiffy(newDate).format('dd/MM/yyyy'));

      _firstDueDateController = PaymentBloc().validateFirstDueDate(
        context,
        _firstDueDateController,
        Jiffy(newDate),
      );

      if (_firstDueDateController.isValid) {
        PaymentState().modifiedSelectedSeries.isModified = true;
        PaymentState().modifiedSelectedSeries.dueDate.date = Jiffy(newDate);
        PaymentState().modifiedSelectedSeries.interestDate =
            SeriesCalcBloc().calculateSeriesInterestDate(
          PaymentState().modifiedSelectedSeries,
          PaymentState()
              .modifiedPaymentSeries
              .where((series) => PaymentBloc().isUpfrontType(series.type))
              .length,
        );

        SeriesPrices seriesNominalPrice = PaymentBloc()
            .calculateSeriesPriceFromTotal(
                _totalPriceController.controller.numberValue);

        SeriesPrices seriesFuturePrice = PaymentBloc()
            .calculateSeriesPriceFromNominal(seriesNominalPrice.seriesValue);

        PaymentState().modifiedSelectedSeries.prices.nominal.seriesTotal =
            seriesNominalPrice.seriesTotal;

        _nominalPriceController.controller
            .updateValue(seriesNominalPrice.seriesValue);
        _futurePriceController.controller
            .updateValue(seriesFuturePrice.seriesValue);
      }
    }
  }

  Widget _buildSeriesNumberOfPayments(bool isEnabled) {
    return Padding(
      padding: Style.iconPadding,
      child: Row(
        children: <Widget>[
          Padding(
            padding: Style.contentPadding,
            child: Icon(
              Icons.timelapse,
              size: Style.iconSize,
            ),
          ),
          Expanded(
            child: TextFieldCustom(
              componentKey: Key('view_series_number_of_payments_field'),
              controller: _numberOfPaymentsController.controller,
              label: I18n.of(context).numberOfPayments,
              textInputType: TextInputType.number,
              errorText: _numberOfPaymentsController.errorText,
              fieldIsValid: _numberOfPaymentsController.isValid,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: _onChangedNumberOfPayments,
              isEnabled: isEnabled,
            ),
          ),
        ],
      ),
    );
  }

  _onChangedNumberOfPayments(String newValue) {
    _numberOfPaymentsController.controller.value =
        _numberOfPaymentsController.controller.value.copyWith(text: newValue);

    _numberOfPaymentsController = PaymentBloc().validateNumberOfPayments(
      context,
      _numberOfPaymentsController,
      widget.accessMode == AccessMode.edit,
    );

    PaymentState().modifiedSelectedSeries.numberOfPayments =
        int.parse(newValue == '' ? '0' : newValue ?? '0');

    SeriesPrices seriesPrice = PaymentBloc().calculateSeriesPriceFromNominal(
        _nominalPriceController.controller.numberValue);

    _futurePriceController.controller.updateValue(seriesPrice.seriesValue);
    _totalPriceController.controller.updateValue(seriesPrice.seriesTotal);
  }

  Widget _buildSeriesNominalPrice(bool isEnabled) {
    return _buildSeriesPrice(
        Icons.attach_money,
        I18n.of(context).nominalPaymentPrice,
        _nominalPriceController,
        _handleOnChangedNominalPrice,
        isEnabled);
  }

  _handleOnChangedNominalPrice(String newValue) {
    _nominalPriceController.controller.value =
        _nominalPriceController.controller.value.copyWith(text: newValue);

    _nominalPriceController = PaymentBloc()
        .validateSeriesNominalPrice(context, _nominalPriceController);

    SeriesPrices seriesPrice = PaymentBloc().calculateSeriesPriceFromNominal(
      _nominalPriceController.controller.numberValue,
    );
    _futurePriceController.controller.updateValue(seriesPrice.seriesValue);
    _totalPriceController.controller.updateValue(seriesPrice.seriesTotal);
  }

  Widget _buildSeriesFuturePrice(bool isEnabled) {
    return _buildSeriesPrice(Icons.today, I18n.of(context).futurePaymentPrice,
        _futurePriceController, _handleOnChangedFuturePrice, isEnabled);
  }

  _handleOnChangedFuturePrice(String newValue) {
    _futurePriceController.controller.value =
        _futurePriceController.controller.value.copyWith(text: newValue);

    _futurePriceController =
        PaymentBloc().validateSeriesPrice(context, _futurePriceController);

    SeriesPrices seriesPrice = PaymentBloc().calculateSeriesPriceFromFuture(
        _futurePriceController.controller.numberValue);
    _nominalPriceController.controller.updateValue(seriesPrice.seriesValue);
    _totalPriceController.controller.updateValue(seriesPrice.seriesTotal);
  }

  Widget _buildSeriesTotalPrice(bool isEnabled) {
    return _buildSeriesPrice(Icons.domain, I18n.of(context).total,
        _totalPriceController, _handleOnChangedTotalPrice, isEnabled);
  }

  _handleOnChangedTotalPrice(String newValue) {
    _totalPriceController.controller.value =
        _totalPriceController.controller.value.copyWith(text: newValue);

    _totalPriceController =
        PaymentBloc().validateSeriesPrice(context, _totalPriceController);

    SeriesPrices seriesNominalPrice = PaymentBloc()
        .calculateSeriesPriceFromTotal(
            _totalPriceController.controller.numberValue);

    SeriesPrices seriesFuturePrice = PaymentBloc()
        .calculateSeriesPriceFromNominal(seriesNominalPrice.seriesValue);

    PaymentState().modifiedSelectedSeries.prices.nominal.seriesTotal =
        seriesNominalPrice.seriesTotal;

    _nominalPriceController.controller
        .updateValue(seriesNominalPrice.seriesValue);
    _futurePriceController.controller
        .updateValue(seriesFuturePrice.seriesValue);
  }

  Widget _buildSeriesPrice(
      IconData icon,
      String label,
      FieldStatusMoneyMasked fieldController,
      Function onChanged,
      bool isEnabled) {
    return Padding(
      padding: Style.iconPadding,
      child: Row(
        children: <Widget>[
          Padding(
            padding: Style.contentPadding,
            child: Icon(
              icon,
              size: Style.iconSize,
            ),
          ),
          Expanded(
            child: TextFieldCustom(
              componentKey: Key('view_series_price_field'),
              controller: fieldController.controller,
              label: label,
              textInputType: TextInputType.number,
              errorText: fieldController.errorText,
              helperText: fieldController.infoText,
              fieldIsValid: fieldController.isValid,
              onChanged: onChanged,
              isEnabled: isEnabled ?? false,
            ),
          ),
        ],
      ),
    );
  }
}
