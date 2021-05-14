import 'package:flutter/material.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/style.dart';

class CompanyWelcomePage extends StatefulWidget {
  CompanyWelcomePage({Key key}) : super(key: key);

  @override
  _CompanyWelcomePageState createState() => _CompanyWelcomePageState();
}

class _CompanyWelcomePageState extends State<CompanyWelcomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Container(
          child: Stack(
            children: <Widget>[
              _buildBackground(),
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: Style.horizontal(8)),
                      child: Image.asset(
                        "assets/login/app_logo.png",
                        width: Style.horizontal(30),
                        fit: BoxFit.fill,
                      ),
                    ),
                    Image.asset(
                      "assets/invite/handshake.png",
                      width: Style.horizontal(50),
                      height: Style.horizontal(50),
                      fit: BoxFit.fill,
                    ),
                    Wrap(
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.vertical,
                      spacing: Style.horizontal(4),
                      children: <Widget>[
                        Text(
                          I18n.of(context).welcomeTo,
                          style: Style.mainTheme.textTheme.bodyText1,
                        ),
                        Text(
                          AuthenticationState().user.companyName,
                          style: Style.inviteCompanyNameText,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: Style.horizontal(80),
                      height: Style.horizontal(12),
                      child: RaisedButton(
                        textColor: Style.textButtonColorPrimary,
                        onPressed: () async {
                          await Navigator.pushNamedAndRemoveUntil(
                              context, "/", (route) => route.isFirst);
                        },
                        child: Text(I18n.of(context).startSelling,
                            style: Style
                                .mainTheme.appBarTheme.textTheme.headline6),
                      ),
                    ),
                    Text(
                      I18n.of(context).goodSales,
                      style: Style.mainTheme.textTheme.bodyText1,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
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
