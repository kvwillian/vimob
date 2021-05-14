import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vimob/blocs/utils/global_settings_bloc.dart';
import 'package:vimob/home_page.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/global_settings_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/login_page.dart';
import 'package:vimob/ui/invite/company_invite_page.dart';
import 'package:vimob/utils/animation/widget_animation.dart';
import 'package:vimob/utils/widgets/splash_screen.dart';

import 'first_access_page.dart';

/// [CheckUser] will check if user is logged.
/// If true, redirect to HomePage.
/// If false, redirect to LoginPage.
class CheckUser extends StatefulWidget {
  CheckUser({
    Key key,
    @required this.authenticationState,
    @required this.context,
  }) : super(key: key);

  final AuthenticationState authenticationState;
  final BuildContext context;

  @override
  _CheckUserState createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    super.initState();
    _updateMessage(context);

    Locale locale = Localizations.localeOf(widget.context);
    widget.authenticationState
        .checkLogin(locale: locale, context: widget.context);
  }

  @override
  Widget build(BuildContext context) {
    var authenticationState = Provider.of<AuthenticationState>(context);
    Style.devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return WillPopScope(
      onWillPop: () async {
        exit(exitCode);
      },
      child: StreamBuilder<bool>(
          stream: authenticationState.isLogged,
          builder: (context, isLogged) {
            if (!isLogged.hasData)
              return WidgetAnimation(child: SplashScreen());

            if (!isLogged.data) return WidgetAnimation(child: LoginPage());

            if (authenticationState.user.uid == null)
              return WidgetAnimation(child: SplashScreen());

            if (authenticationState.user.firstAccess ?? true)
              return WidgetAnimation(child: FirstAccessPage());

            if (authenticationState.user.company == null)
              return WidgetAnimation(child: CompanyInvitePage());

            return WidgetAnimation(child: HomePage());
          }),
    );
  }

  _updateMessage(BuildContext context) async {
    if (!GlobalSettingsBloc().versionValidation(
        int.parse(GlobalSettingsState().globalSettings.packageInfo.buildNumber),
        GlobalSettingsState().globalSettings.minimumVersion)) {
      print(int.parse(
          GlobalSettingsState().globalSettings.packageInfo.buildNumber));
      print(GlobalSettingsState().globalSettings.minimumVersion);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: UpdateMessageDialog(),
        ),
      );
    }
  }
}

class UpdateMessageDialog extends StatelessWidget {
  const UpdateMessageDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        height: Style.horizontal(40),
        width: Style.horizontal(80),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 3,
                      child: Text(
                        I18n.of(context).updateMessage,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                width: double.infinity,
                child: FlatButton(
                  onPressed: _redirectToStore,
                  child: Center(child: Text(I18n.of(context).update)),
                )),
          ],
        ),
      ),
    );
  }

  _redirectToStore() async {
    if (Platform.isAndroid) {
      await launch(
          "https://play.google.com/store/apps/details?id=br.com.mega.vimob");
    } else {
      await launch(
          "https://apps.apple.com/us/app/vimob-vendas-imobiliárias/id1450258086");
    }
  }
}
