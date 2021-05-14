import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/style.dart';

class InvalidFieldsDialog extends StatelessWidget {
  const InvalidFieldsDialog({
    Key key,
  }) : super(key: key);

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
            I18n.of(context).oops,
            style: Style.mainTheme.textTheme.headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Style.horizontal(4)),
      child: Text(
        //I18n.of(context).diluteSeries,
        'Antes de salvar a série, corrija os campos em vermelho.',
        style: Style.mainTheme.textTheme.bodyText2,
        textAlign: TextAlign.center,
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
            //I18n.of(context).ok,
            'Ok',
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
    Navigator.pop(context);
  }
}
