import 'package:flutter/material.dart';
import 'package:vimob/style.dart';

class AppBarResponsive {
  Widget show(
      {@required BuildContext context,
      @required String title,
      VoidCallback onBack,
      List<Widget> actions,
      Widget leading,
      double preferredSize,
      Color appBarColor,
      double elevation}) {
    return PreferredSize(
      preferredSize: MediaQuery.of(context).orientation == Orientation.portrait
          ? Size.fromHeight(preferredSize ?? Style.vertical(20))
          : Size.fromHeight(Style.vertical(12.5)),
      child: Container(
        padding: EdgeInsets.only(top: Style.vertical(3.5)),
        decoration:
            BoxDecoration(color: appBarColor ?? Style.brandColor, boxShadow: [
          new BoxShadow(
            color: Colors.transparent,
            blurRadius: elevation ?? 2.0,
          ),
        ]),
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Style.horizontal(3)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    left: Style.horizontal(3), right: Style.horizontal(3)),
                child: leading ??
                    InkWell(
                      child: Icon(Icons.arrow_back,
                          key: Key("arrow_back"),
                          size: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? Style.horizontal(7)
                              : Style.horizontal(3),
                          color: Style.mainTheme.appBarTheme.iconTheme.color),
                      onTap: onBack ?? () => Navigator.pop(context),
                    ),
              ),
              Expanded(
                child: Text(
                  title ?? "Title",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? Style.mainTheme.appBarTheme.textTheme.headline6
                          : Style.mainTheme.appBarTheme.textTheme.headline6
                              .copyWith(fontSize: 15),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: Style.horizontal(4),
                ),
                child: Container(
                  height: Style.vertical(4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[...actions ?? []],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  // Widget show(
  //     {@required BuildContext context,
  //     @required String headline6,
  //     double height,
  //     VoidCallback onBack,
  //     List<Widget> actions,
  //     IconButton leading,
  //     double elevation}) {
  //   return PreferredSize(
  //     preferredSize: Size.fromHeight(height ?? Style.horizontal(11)),
  //     child: AppBar(
  //       elevation: elevation ?? 4,
  //       automaticallyImplyLeading: false,
  //       flexibleSpace: Container(
  //         width: double.infinity,
  //         child: Padding(
  //           padding: EdgeInsets.only(top: Style.horizontal(7)),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: <Widget>[
  //               Padding(
  //                 padding: EdgeInsets.only(
  //                     left: Style.horizontal(3), right: Style.horizontal(3)),
  //                 child: leading ??
  //                     InkWell(
  //                       child: Icon(Icons.arrow_back,
  //                           key: Key("arrow_back"),
  //                           size: Style.horizontal(7),
  //                           color: Style.mainTheme.appBarTheme.iconTheme.color),
  //                       onTap: onBack ?? () => Navigator.pop(context),
  //                     ),
  //               ),
  //               Expanded(
  //                 child: Text(
  //                   headline6 ?? "Title",
  //                   style: Style.mainTheme.appBarTheme.textTheme.headline6,
  //                 ),
  //               ),
  //               ...actions ?? [Container()]
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget showWithDrawer(
      {BuildContext context,
      String headline6,
      List<Widget> actions,
      GlobalKey<ScaffoldState> scaffoldsKey}) {
    var appBar = PreferredSize(
      preferredSize: Size.fromHeight(Style.vertical(20)),
      child: Container(
        padding: EdgeInsets.only(top: Style.vertical(3.5)),
        decoration: BoxDecoration(color: Style.brandColor, boxShadow: [
          new BoxShadow(
            color: Colors.black12,
            blurRadius: 2.0,
          ),
        ]),
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Style.horizontal(3)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Style.horizontal(3)),
                child: InkWell(
                    key: Key("drawer"),
                    onTap: () => scaffoldsKey.currentState.openDrawer(),
                    child: Icon(
                      Icons.menu,
                      size: Style.mainTheme.appBarTheme.iconTheme.size,
                      color: Style.mainTheme.appBarTheme.iconTheme.color,
                    )),
              ),
              Expanded(
                child: Text(
                  headline6 ?? "Title",
                  style: Style.mainTheme.appBarTheme.textTheme.headline6,
                ),
              ),
              ...actions
            ],
          ),
        ),
      ),
    );

    return appBar;
  }
  // Widget showWithDrawer(
  //     {BuildContext context,
  //     String headline6,
  //     double height,
  //     List<Widget> actions,
  //     GlobalKey<ScaffoldState> scaffoldsKey}) {
  //   var appBar = PreferredSize(
  //     preferredSize: Size.fromHeight(height ?? Style.horizontal(11)),
  //     child: AppBar(
  //       flexibleSpace: Container(
  //         width: double.infinity,
  //         child: Padding(
  //           padding: EdgeInsets.only(top: Style.horizontal(8)),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: <Widget>[
  //               Padding(
  //                 padding:
  //                     EdgeInsets.symmetric(horizontal: Style.horizontal(3)),
  //                 child: InkWell(
  //                     key: Key("drawer"),
  //                     onTap: () => scaffoldsKey.currentState.openDrawer(),
  //                     child: Icon(
  //                       Icons.menu,
  //                       size: Style.mainTheme.appBarTheme.iconTheme.size,
  //                       color: Style.mainTheme.appBarTheme.iconTheme.color,
  //                     )),
  //               ),
  //               Expanded(
  //                 child: Text(
  //                   headline6 ?? "Title",
  //                   style: Style.mainTheme.appBarTheme.textTheme.headline6,
  //                 ),
  //               ),
  //               ...actions
  //             ],
  //           ),
  //         ),
  //       ),
  //       leading: Container(),
  //     ),
  //   );

  //   return appBar;
  // }
}
