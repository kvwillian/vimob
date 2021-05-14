import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/style.dart';

class InsufficientValueDialog extends StatelessWidget {
  const InsufficientValueDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
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
      ),
    );
  }

  _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Style.horizontal(5),
        left: Style.horizontal(5),
        right: Style.horizontal(5),
      ),
      child: Row(
        children: <Widget>[
          Text(
            I18n.of(context).oops,            
            style: Style.mainTheme.textTheme.headline6
                .copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Style.horizontal(5)),
      child: Row(
        children: <Widget>[
          Text(
            I18n.of(context).insufficientValue,            
            style: Style.mainTheme.textTheme.bodyText2,
            textAlign: TextAlign.center,
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
            I18n.of(context).back,
            () => _handleOnTapConfirm(context),
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

  _handleOnTapConfirm(BuildContext context) async {
    Navigator.pop(context);
  }
}
