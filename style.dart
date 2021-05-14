import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Style {
  factory Style() => instance;

  static var instance = Style._internal();
  Style._internal();

  static double devicePixelRatio;

  //responsive
  static double maxHeight;
  static double maxWidth;

  void responsiveInit({BoxConstraints constraints}) {
    maxHeight = constraints.maxHeight;
    maxWidth = constraints.maxWidth;
  }

  static double vertical(double percent) {
    return (maxHeight / 100) * percent;
  }

  static double horizontal(double percent) {
    return (maxWidth / 100) * percent;
  }

  static ThemeData mainTheme = ThemeData.light().copyWith(
    primaryColor: brandColor,
    appBarTheme: AppBarTheme(
        actionsIconTheme:
            IconThemeData(size: horizontal(6), color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white, size: horizontal(6)),
        textTheme: TextTheme(
          headline6: TextStyle(
              color: Colors.white,
              fontSize: horizontal(5),
              fontWeight: FontWeight.bold),
        )),
    textTheme: TextTheme(
      bodyText2: TextStyle(color: textDefaultColor, fontSize: horizontal(3.5)),
      bodyText1: TextStyle(color: Colors.white, fontSize: horizontal(3.5)),
      headline6: TextStyle(color: textDefaultColor, fontSize: horizontal(4)),
      subtitle1: TextStyle(
        color: Color(0xFF6A6C7D),
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      button: TextStyle(
        fontSize: horizontal(3),
      ),
    ),
    iconTheme: IconThemeData(color: Color(0xFF8C8C8C), size: horizontal(5)),
    buttonColor: buttonColor,
    buttonTheme: ButtonThemeData(
      buttonColor: buttonColor,
      height: vertical(5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.orange,
    ),
    tabBarTheme: TabBarTheme(
      unselectedLabelStyle:
          TextStyle(color: Colors.white, fontSize: horizontal(3)),
      labelStyle: TextStyle(color: Colors.white, fontSize: horizontal(3)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      errorStyle: TextStyle(fontSize: horizontal(2.5)),
      helperStyle: TextStyle(fontSize: horizontal(2.5)),
      hintStyle: TextStyle(color: Colors.grey),
      contentPadding:
          EdgeInsets.only(left: horizontal(2), bottom: horizontal(1)),
      isDense: true,
      labelStyle:
          TextStyle(fontSize: horizontal(4.5), fontWeight: FontWeight.normal),
    ),
  );

  //Color
  static Color brandColor = Color(0xFF4990E2);
  static Color disableTextColor = Color(0xFFD9D9D9);

  //Text
  static Color textDefaultColor = Color(0xFF6A6C7D);
  static Color textFadedColor = Color(0xFF8C8C8C);
  static Color textFadedColorTransparent = Color(0x338C8C8C);
  static Color textOrangeColor = Color(0xFFF9901C);
  static Color greenColor = Color(0xFF87DE42);

  static TextStyle inviteCompanyNameText = TextStyle(
      color: Colors.white,
      fontSize: horizontal(8),
      fontWeight: FontWeight.bold);

  static TextStyle titleSecondaryText = mainTheme.textTheme.headline6
      .copyWith(color: textDefaultColor, fontWeight: FontWeight.bold);

  static TextStyle titleBlackBold = mainTheme.textTheme.headline6
      .copyWith(color: Colors.black, fontWeight: FontWeight.bold);

  static TextStyle subtitleText = mainTheme.textTheme.headline6
      .copyWith(color: textFadedColor, fontSize: horizontal(2.5));

  static TextStyle saveButtonText = mainTheme.textTheme.headline6
      .copyWith(color: textOrangeColor, fontWeight: FontWeight.bold);

  static TextStyle nominalFutureText = mainTheme.textTheme.headline6
      .copyWith(color: brandColor, fontWeight: FontWeight.bold, fontSize: 12);

  static TextStyle fadedTitleText = mainTheme.textTheme.headline6.copyWith(
      color: textFadedColor,
      fontSize: horizontal(3.5),
      fontWeight: FontWeight.normal);

  static TextStyle paymentSeriesText = mainTheme.textTheme.headline6.copyWith(
      color: textFadedColor,
      fontSize: horizontal(3.5),
      fontWeight: FontWeight.normal);

  static TextStyle developmentCardInfoText = mainTheme.textTheme.bodyText2
      .copyWith(
          color: textDefaultColor,
          fontWeight: FontWeight.normal,
          fontSize: Style.horizontal(3));
  static TextStyle textDisable = mainTheme.textTheme.bodyText2.copyWith(
    color: disableTextColor,
  );

  static TextStyle textMetricsUnitCard =
      mainTheme.textTheme.bodyText2.copyWith(fontSize: Style.horizontal(2));
  static TextStyle textProposalDetailsTitleTabs =
      mainTheme.textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold);
  static TextStyle textProposalDetailsTitlePage =
      mainTheme.textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold);
  static TextStyle textHighlightBold = mainTheme.textTheme.headline6
      .copyWith(fontWeight: FontWeight.bold, color: Colors.blueAccent);
  static TextStyle textHighlight =
      mainTheme.textTheme.headline6.copyWith(color: Colors.blueAccent);
  static TextStyle textDevelopmentNameTitle = TextStyle(
      color: textDefaultColor,
      fontSize: horizontal(8),
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic);

  //Forms

  static TextStyle inputText = mainTheme.textTheme.bodyText2
      .copyWith(fontSize: horizontal(4), fontWeight: FontWeight.normal);
  static TextStyle inputInviteCodeText = mainTheme.textTheme.bodyText2
      .copyWith(fontSize: horizontal(5.5), fontWeight: FontWeight.normal);

  static Color inputIconColor = Colors.blue;
  static double inputIconSize = horizontal(5.5);

  //Drawer
  static TextStyle companyOptionText =
      mainTheme.textTheme.bodyText2.copyWith(fontSize: horizontal(3));

  //ErrorMessage
  static TextStyle snackBarText = mainTheme.textTheme.bodyText1;

  //BottomNavigation
  static Color unselectedOptions = Color(0xFF244770);
  static Color selectedOptions = Colors.white;

  //Button
  static Color buttonCleanFilterColor = Color(0xFF2069BD);
  static Color buttonColor = Colors.orange;
  static Color buttonColorSecondary = Colors.white;
  static Color textButtonColorPrimary = Colors.white;
  static Color textButtonColorSecondary = Colors.orange;
  static Color textButtonColorLink = Colors.blue;
  static Animation<Color> loadingColor =
      AlwaysStoppedAnimation<Color>(Colors.white);
  static Animation<Color> loadingColorSecondary =
      AlwaysStoppedAnimation<Color>(Colors.orange);

  //Icons
  static IconThemeData scanCodeIconTheme =
      IconThemeData(color: Colors.white, size: horizontal(6));
  static EdgeInsets iconPadding = const EdgeInsets.only(
    top: 20.0,
    left: 10.0,
    right: 10.0,
  );
  static EdgeInsets contentPadding = EdgeInsets.all(10.0);
  static double iconSize = 24;

  static double savedProposalIconSize = 200;
  static TextStyle savedProposalText = mainTheme.textTheme.headline6
      .copyWith(color: brandColor, fontWeight: FontWeight.bold, fontSize: 24);
}
