import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/sales_mirror/development_card.dart';
import 'package:vimob/utils/animation/widget_animation.dart';

class SalesMirrorTab extends StatefulWidget {
  const SalesMirrorTab({
    Key key,
    @required this.developmentState,
    this.user,
  }) : super(key: key);

  final DevelopmentState developmentState;
  final User user;

  @override
  _MirrorPageState createState() => _MirrorPageState();
}

class _MirrorPageState extends State<SalesMirrorTab> {
  @override
  void initState() {
    super.initState();
    widget.developmentState.fetchDevelopments(
        companyId: widget.user.company, uid: widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Development>>(
        stream: widget.developmentState.developments,
        builder: (context, developments) {
          if (developments.hasData && developments.data.isNotEmpty) {
            return WidgetAnimation(
              child: ListView(
                  shrinkWrap: true,
                  children: developments.data
                      .map(
                        (development) => DevelopmentCard(
                          key: Key(
                              "development_card_${developments.data.indexOf(development)}"),
                          development: development,
                        ),
                      )
                      .toList()),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    "assets/sales_mirror/sales_mirror.svg",
                    height: Style.horizontal(30),
                    color: Style.mainTheme.iconTheme.color,
                  ),
                  Padding(
                    padding: EdgeInsets.all(Style.horizontal(4)),
                    child: Text(I18n.of(context).noDevelopmentsAvailable),
                  ),
                ],
              ),
            );
          }
        });
  }
}
