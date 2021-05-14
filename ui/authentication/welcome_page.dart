import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/style.dart';
import 'package:vimob/utils/animation/widget_animation.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({
    Key key,
    this.message,
    this.onTimeEnd,
  }) : super(key: key);

  final String message;
  final Function onTimeEnd;

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    _startTimeout(Duration(seconds: 3));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Stack(
          children: <Widget>[
            _buildBackground(),
            Center(
              child: WidgetAnimation(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(I18n.of(context).welcomeText,
                        style: Style.mainTheme.textTheme.bodyText1),
                    Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(I18n.of(context).goodSales,
                          style: Style.mainTheme.textTheme.bodyText1),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _startTimeout(Duration timeout) {
    Timer(timeout, widget.onTimeEnd);
  }

  Center _buildBackground() {
    return Center(
      child: Image.asset(
        "assets/common/splash_screen.png",
        height: Style.vertical(100),
        width: Style.horizontal(100),
        fit: BoxFit.fill,
      ),
    );
  }
}
