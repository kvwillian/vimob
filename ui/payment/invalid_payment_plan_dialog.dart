import 'package:flutter/material.dart';
import 'package:vimob/blocs/payment/payment_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/style.dart';

class InvalidPaymentPlanDialog extends StatefulWidget {
  InvalidPaymentPlanDialog({
    Key key,
    this.errorMessages,
  }) : super(key: key);
  final List<String> errorMessages;

  @override
  _InvalidPaymentPlanDialog createState() => _InvalidPaymentPlanDialog();
}

class _InvalidPaymentPlanDialog extends State<InvalidPaymentPlanDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildTitle(context),
          _buildMessageList(context),
          Divider(),
          _buildButtonBar(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Style.horizontal(5),
        horizontal: Style.horizontal(5),
      ),
      child: Row(
        children: <Widget>[
          Text(
            I18n.of(context).attention,
            style: Style.mainTheme.textTheme.headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return Flexible(
      child: ListView(
        shrinkWrap: true,
        children: widget.errorMessages
            .map((message) => _buildSeriesListRow(message))
            .toList(),
      ),
    );
  }

  Widget _buildSeriesListRow(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Style.horizontal(5),
        vertical: Style.horizontal(2.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message,
            style: Style.mainTheme.textTheme.bodyText2,
            softWrap: true,
            textWidthBasis: TextWidthBasis.longestLine,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Style.horizontal(4)),
      child: Row(
        children: <Widget>[
          _buildButton(
            context,
            I18n.of(context).ok,
            () => _handleOnTapOk(context),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Function onTap) {
    return Expanded(
      child: Center(
        child: InkWell(
          onTap: onTap,
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

  _handleOnTapOk(BuildContext context) {
    PaymentBloc().resetSelectedSeriesToDilute();
    Navigator.pop(context);
  }
}
