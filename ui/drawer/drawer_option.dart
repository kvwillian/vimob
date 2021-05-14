import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vimob/style.dart';

class DrawerOption extends StatelessWidget {
  const DrawerOption({
    Key key,
    this.onTap,
    this.text,
    this.iconData,
    this.iconColor,
    this.svgPath,
    this.btnKey,
    this.iconSize,
  }) : super(key: key);

  final GestureTapCallback onTap;
  final String text;
  final IconData iconData;
  final Color iconColor;
  final String svgPath;
  final double iconSize;
  final Key btnKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Style.horizontal(2)),
      child: InkWell(
        key: btnKey,
        onTap: onTap,
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  left: Style.horizontal(5), right: Style.horizontal(2)),
              child: svgPath != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: Style.horizontal(1),
                      ),
                      child: SvgPicture.asset(
                        svgPath,
                        width: iconSize ?? Style.mainTheme.iconTheme.size,
                        color: iconColor ?? Style.mainTheme.iconTheme.color,
                      ),
                    )
                  : Icon(
                      iconData,
                      color: iconColor ?? Style.mainTheme.iconTheme.color,
                      size: Style.horizontal(8),
                    ),
            ),
            Text(text),
          ],
        ),
      ),
    );
  }
}
