import 'package:flutter/material.dart';
import 'package:vimob/style.dart';

class FABMenu extends StatefulWidget {
  /// Float Action Button Menu
  /// ==========================
  ///
  /// [options] List of [FABMenuOptionsProperties]
  ///
  /// [FABMenuOptionsProperties] is required all fields in constructor
  FABMenu({
    Key key,
    @required this.options,
    this.componentKey,
    this.mainIcon,
    this.yOffset,
    this.xOffset,
  }) : super(key: key);

  final List<FABMenuOptionProperties> options;
  final Key componentKey;
  final mainIcon;
  final yOffset;
  final xOffset;

  @override
  _FABMenuState createState() => _FABMenuState();
}

class _FABMenuState extends State<FABMenu> with TickerProviderStateMixin {
  AnimationController _fabIconAnimationController;
  double _itemScale = 0;

  @override
  void initState() {
    super.initState();

    _fabIconAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _fabIconAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        ..._buildOptions(widget.options ?? []),
        InkWell(
          key: widget.componentKey,
          borderRadius: BorderRadius.all(Radius.circular(Style.horizontal(50))),
          onTap: () {
            if (_fabIconAnimationController.isCompleted) {
              _fabIconAnimationController.reverse();
            } else {
              _fabIconAnimationController.forward();
            }
            _fabIconAnimationController.addListener(() {
              setState(() {
                _itemScale = _fabIconAnimationController.value;
              });
            });
          },
          child: Container(
            padding: EdgeInsets.all(Style.horizontal(5)),
            margin: EdgeInsets.only(
              top: Style.horizontal(2),
              left: Style.horizontal(2),
              bottom: widget.yOffset ?? Style.horizontal(2),
              right: widget.xOffset ?? Style.horizontal(2),
            ),
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.all(Radius.circular(Style.horizontal(50)))),
            child: AnimatedCrossFade(
              crossFadeState: _fabIconAnimationController.isCompleted
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 100),
              firstChild: Icon(
                widget.mainIcon ?? Icons.edit,
                color: Colors.white,
              ),
              secondChild: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<FABMenuOption> _buildOptions(List<FABMenuOptionProperties> options) {
    return options
        .map((properties) {
          return FABMenuOption(
            itemScale: _itemScale,
            fabMenuOptionProperties: properties,
            fabIconAnimationController: _fabIconAnimationController,
            index: options.indexOf(properties).toDouble(),
          );
        })
        .toList()
        .reversed
        .toList();
  }
}

class FABMenuOption extends StatelessWidget {
  const FABMenuOption({
    Key key,
    @required double itemScale,
    this.fabMenuOptionProperties,
    this.fabIconAnimationController,
    this.index,
  })  : _itemScale = itemScale,
        super(key: key);

  final double _itemScale;
  final double index;
  final AnimationController fabIconAnimationController;
  final FABMenuOptionProperties fabMenuOptionProperties;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 100),
      opacity: _itemScale,
      child: Transform.scale(
        scale: _itemScale,
        origin:
            Offset(Style.horizontal(10), Style.horizontal(20 * (index + 1))),
        child: InkWell(
          key: fabMenuOptionProperties.onTapKey ?? Key("defaultKey"),
          onTap: () {
            fabIconAnimationController.reverse();
            fabMenuOptionProperties.onTap();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Style.horizontal(2)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: fabMenuOptionProperties.textMargin ??
                      EdgeInsets.all(Style.horizontal(2)),
                  padding: fabMenuOptionProperties.textMargin ??
                      EdgeInsets.all(Style.horizontal(2)),
                  decoration: BoxDecoration(
                      color: fabMenuOptionProperties.textBackgroundColor ??
                          Colors.grey[300],
                      borderRadius: BorderRadius.all(
                          Radius.circular(Style.horizontal(4)))),
                  child: fabMenuOptionProperties.text ??
                      Text(
                        "text",
                        style: Style.mainTheme.textTheme.bodyText2,
                      ),
                ),
                Container(
                  width: Style.horizontal(
                      fabMenuOptionProperties.radiusSize ?? 12),
                  height: Style.horizontal(
                      fabMenuOptionProperties.radiusSize ?? 12),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(
                          Radius.circular(Style.horizontal(50)))),
                  child: fabMenuOptionProperties.icon ??
                      Icon(Icons.not_interested, color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FABMenuOptionProperties {
  FABMenuOptionProperties({
    @required this.text,
    @required this.icon,
    @required this.onTap,
    this.onTapKey,
    this.radiusSize,
    this.textMargin,
    this.textBackgroundColor,
    this.textPadding,
  });
  Text text;
  Icon icon;
  Key onTapKey;
  double radiusSize;
  EdgeInsets textMargin;
  EdgeInsets textPadding;
  Color textBackgroundColor;
  GestureTapCallback onTap = () {};
}
