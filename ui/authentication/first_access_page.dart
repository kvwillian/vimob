import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/ui/authentication/welcome_page.dart';

import '../../style.dart';

class FirstAccessPage extends StatefulWidget {
  const FirstAccessPage({Key key}) : super(key: key);

  @override
  _FirstAccessPageState createState() => _FirstAccessPageState();
}

class _FirstAccessPageState extends State<FirstAccessPage> {
  CarouselController _carouselController;
  var _pages = <Widget>[];
  var _currentIndex = 0;

  @override
  void initState() {
    _carouselController = CarouselController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      _pages = items();
    }

    return Material(
      child: Stack(
        children: <Widget>[
          _buildBackground(),
          _currentIndex != 0
              ? Column(
                  children: <Widget>[
                    Spacer(),
                    Flexible(
                      flex: 4,
                      child: Center(
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Style.brandColor,
                          ),
                        ),
                      ),
                    ),
                    Spacer(
                      flex: 3,
                    ),
                  ],
                )
              : Container(),
          CarouselSlider(
            carouselController: _carouselController,
            items: _pages,
            options: CarouselOptions(
              viewportFraction: 1,
              enableInfiniteScroll: false,
              height: Style.vertical(100),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          Positioned(
            bottom: 15,
            left: 0,
            width: Style.horizontal(100),
            child: _currentIndex + 1 == _pages.length
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      height: 50,
                      child: RaisedButton(
                        textColor: Style.textButtonColorPrimary,
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => WelcomePage(
                                        onTimeEnd: () async {
                                          AuthenticationState()
                                              .updateFirstAccess(
                                                  AuthenticationState()
                                                      .user
                                                      .uid);
                                          await Navigator
                                              .pushNamedAndRemoveUntil(
                                                  context,
                                                  "/",
                                                  (Route<dynamic> route) =>
                                                      route.isFirst);
                                        },
                                      )));
                        },
                        child:
                            Text(I18n.of(context).startSelling.toUpperCase()),
                      ),
                    ),
                  )
                : _buildSliderIndicator(),
          ),
        ],
      ),
    );
  }

  Row _buildSliderIndicator() {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlineButton(
            textColor: Style.buttonColorSecondary,
            borderSide: BorderSide(style: BorderStyle.none),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => WelcomePage(
                            onTimeEnd: () async {
                              AuthenticationState().updateFirstAccess(
                                  AuthenticationState().user.uid);
                              await Navigator.pushNamedAndRemoveUntil(context,
                                  "/", (Route<dynamic> route) => route.isFirst);
                            },
                          )));
            },
            child: Text(I18n.of(context).skip.toUpperCase()),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _pages.map((page) {
              int index = _pages.indexOf(page);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 7.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Style.buttonColorSecondary.withOpacity(0.9)
                      : Style.buttonColorSecondary.withOpacity(0.4),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: OutlineButton(
            textColor: Style.buttonColorSecondary,
            borderSide: BorderSide(style: BorderStyle.none),
            onPressed: () {
              _carouselController.nextPage();
            },
            child: Text(I18n.of(context).next.toUpperCase()),
          ),
        ),
      ],
    );
  }

  List<Widget> items() {
    return <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: <Widget>[
            Spacer(),
            Flexible(
              flex: 4,
              child: Center(
                child: Image.asset(
                  "assets/login/app_logo.png",
                  width: Style.horizontal(55),
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      I18n.of(context).welcomeVimob,
                      style: Style.mainTheme.appBarTheme.textTheme.headline6,
                    ),
                  ),
                  Text(
                    I18n.of(context).firstAccessWelcomeText,
                    style: Style.mainTheme.textTheme.bodyText1,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      _buildPage(
        centerChild: SvgPicture.asset(
          "assets/login/house.svg",
          height: 175,
        ),
        title: I18n.of(context).showcase,
        description: I18n.of(context).firstAccessShowcaseText,
      ),
      _buildPage(
        centerChild: SvgPicture.asset(
          "assets/login/calendar.svg",
          height: 175,
        ),
        title: I18n.of(context).paymentPlans,
        description: I18n.of(context).firstAccessPaymentPlanText,
      ),
      _buildPage(
          centerChild: SvgPicture.asset(
            "assets/login/handshake.svg",
            height: 125,
          ),
          title: I18n.of(context).negotiation,
          description: I18n.of(context).firstAccessNegotiationText),
    ];
  }

  Padding _buildPage({Widget centerChild, String title, String description}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Spacer(),
          Flexible(
            flex: 4,
            child: Center(child: centerChild ?? Container()),
          ),
          Flexible(
            flex: 3,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    title,
                    style: Style.mainTheme.appBarTheme.textTheme.headline6,
                  ),
                ),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Style.mainTheme.textTheme.bodyText1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
