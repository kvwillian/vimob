import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/style.dart';

class SaveSeriesDialog extends StatelessWidget {
  const SaveSeriesDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        height: Style.horizontal(65),
        width: Style.horizontal(80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.all(Style.horizontal(4)),
                child: Icon(
                  Icons.delete,
                  size: Style.horizontal(15),
                ),
              ),
            ),
            Text(
              'Deseja salvar esta série?',
              //I18n.of(context).removeProposalConfirm,
              style: Style.mainTheme.textTheme.headline6
                  .copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: Style.horizontal(2)),
              child: Text(
                I18n.of(context).removeProposalConfirmText,
                style: Style.mainTheme.textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.only(bottom: Style.horizontal(4)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(I18n.of(context).cancel,
                            style: Style.mainTheme.textTheme.button.copyWith(
                                color: Style.textButtonColorLink,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          int count = 0;
                          Navigator.of(context).popUntil((_) => count++ >= 2);
                        },
                        child: Text(
                          'Salvar',
                          //I18n.of(context).remove,
                          style: Style.mainTheme.textTheme.button.copyWith(
                              color: Style.textButtonColorLink,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
