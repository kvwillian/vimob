import 'package:flutter/material.dart';
import 'package:vimob/style.dart';

class LoadingRaisedButton extends StatelessWidget {
  const LoadingRaisedButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      textColor: Colors.white,
      onPressed: () {},
      child: SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(
            valueColor: Style.loadingColor,
          )),
    );
  }
}
