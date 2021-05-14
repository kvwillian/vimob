import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/payment/payment.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/payment/dilute_series_dialog.dart';

class RemoveSeriesDialog extends StatelessWidget {
  const RemoveSeriesDialog({
    Key key,
    this.accessMode,
  }) : super(key: key);

  final AccessMode accessMode;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildIcon(),
          _buildConfirmText(context),
          _buildDescription(context),
          Divider(),
          _buildButtonBar(context),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Style.horizontal(4)),
        child: Icon(Icons.delete, size: Style.horizontal(15)),
      ),
    );
  }

  _buildConfirmText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Style.horizontal(2)),
      child: Text(
        I18n.of(context).removeSeriesConfirm,
        style: Style.mainTheme.textTheme.headline6
            .copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Style.horizontal(4)),
      child: Text(
        I18n.of(context).diluteSeries,
        style: Style.mainTheme.textTheme.bodyText2,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildButtonBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildButton(
          context,
          I18n.of(context).cancel,
          () => _handleOnTapCancel(context),
        ),
        _buildButton(
          context,
          I18n.of(context).remove,
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
    Navigator.pop(context);
  }

  _handleOnTapConfirm(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => DiluteSeriesDialog(
        type: PriceDifferenceType.remove,
        accessMode: accessMode,
      ),
    );

    Navigator.pop(context);
  }
}
