import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:vimob/style.dart';

class ShowSnackbar {
  factory ShowSnackbar() => instance;

  static var instance = ShowSnackbar._internal();
  ShowSnackbar._internal();

  FlushbarStatus snackbarStatus = FlushbarStatus.DISMISSED;

  void showSnackbarError(BuildContext context, String text) {
    text = text.replaceAll("Exception: ", "");

    if (snackbarStatus == FlushbarStatus.IS_HIDING ||
        snackbarStatus == FlushbarStatus.DISMISSED) {
      Flushbar(
        key: Key("snack_key"),
        duration: Duration(milliseconds: 1500),
        maxWidth: Style.horizontal(95),
        margin: EdgeInsets.only(bottom: Style.horizontal(4)),

        flushbarStyle: FlushbarStyle.FLOATING,
        //padding: EdgeInsets.all(Style.vertical(2)),
        messageText: Text(
          text ?? "Ops! Algo deu errado!",
          style: Style.snackBarText,
          key: Key("snackbar_text"),
        ),
        // icon: Icon(Icons.error_outline),
        borderRadius: 8,
        //margin: EdgeInsets.all(Style.vertical(2)),
        onStatusChanged: (FlushbarStatus status) {
          snackbarStatus = status;
        },
      )..show(context);
    }
  }

  void showSnackbarSuccess(BuildContext context, String text) {
    if (snackbarStatus == FlushbarStatus.IS_HIDING ||
        snackbarStatus == FlushbarStatus.DISMISSED) {
      Flushbar(
        key: Key("snack_key"),
        duration: Duration(milliseconds: 1500),
        maxWidth: Style.horizontal(95),
        margin: EdgeInsets.only(bottom: Style.horizontal(4)),

        flushbarStyle: FlushbarStyle.FLOATING,
        //padding: EdgeInsets.all(Style.vertical(2)),
        backgroundColor: Colors.green,
        messageText: Text(
          text ?? "Ops! Algo deu errado!",
          style: Style.snackBarText,
          key: Key("snackbar_text"),
        ),
        // icon: Icon(Icons.error_outline),
        borderRadius: 8,
        //margin: EdgeInsets.all(Style.vertical(2)),
        onStatusChanged: (FlushbarStatus status) {
          snackbarStatus = status;
        },
      )..show(context);
    }
  }

  void showSnackbarCustom(BuildContext context, String text,
      {Duration duration = const Duration(milliseconds: 1500),
      Color backgroundColor,
      TextStyle textStyle}) {
    if (snackbarStatus == FlushbarStatus.IS_HIDING ||
        snackbarStatus == FlushbarStatus.DISMISSED) {
      Flushbar(
        key: Key("snack_key"),
        duration: duration,
        flushbarStyle: FlushbarStyle.FLOATING,

        maxWidth: Style.horizontal(95),
        margin: EdgeInsets.only(bottom: Style.horizontal(4)),

        backgroundColor: backgroundColor ?? Style.brandColor,
        messageText: Text(
          text ?? "Ops! Algo deu errado!",
          style: textStyle ?? Style.snackBarText,
          key: Key("snackbar_text"),
        ),
        // icon: Icon(Icons.error_outline),
        borderRadius: 8,
        //margin: EdgeInsets.all(Style.vertical(2)),
        onStatusChanged: (FlushbarStatus status) {
          snackbarStatus = status;
        },
      )..show(context);
    }
  }
}
