import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/style.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({Key key, this.text, this.title, this.onTap})
      : super(key: key);

  final String text;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                      title ?? "",
                      style: Style.mainTheme.textTheme.headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(text ?? ""),
                ],
              ),
            ),
            SizedBox(
              height: Style.vertical(8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Center(
                        child: Text(I18n.of(context).cancel,
                            style: Style.mainTheme.textTheme.button.copyWith(
                                color: Style.textButtonColorLink,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: onTap ?? null,
                      child: Center(
                        child: Text(
                          I18n.of(context).confirm,
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
      ),
    );
  }
}
