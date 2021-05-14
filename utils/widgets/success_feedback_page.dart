import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vimob/style.dart';

class SuccessFeedbackPage extends StatefulWidget {
  SuccessFeedbackPage({
    Key key,
    this.message,
    this.onTimeEnd,
  }) : super(key: key);

  final String message;
  final Function onTimeEnd;

  @override
  _SuccessFeedbackPageState createState() => _SuccessFeedbackPageState();
}

class _SuccessFeedbackPageState extends State<SuccessFeedbackPage> {
  @override
  void initState() {
    _startTimeout(Duration(seconds: 2));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(
                Icons.done,
                size: Style.savedProposalIconSize,
                color: Style.brandColor,
              ),
              Text(
                widget.message,
                style: Style.savedProposalText,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _startTimeout(Duration timeout) {
    Timer(timeout, widget.onTimeEnd);
  }
}
