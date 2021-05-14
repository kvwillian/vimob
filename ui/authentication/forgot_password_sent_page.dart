import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';

class ForgotPasswordSentPage extends StatelessWidget {
  const ForgotPasswordSentPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authenticationState = Provider.of<AuthenticationState>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBarResponsive().show(
          context: context,
          title: I18n.of(context).validateYourEmail,
          onBack: () async {
            AuthenticationState().cleanForm();
            if (authenticationState.isLogged.value) {
              await authenticationState.signOut();
            }
            await Navigator.pushNamedAndRemoveUntil(
                context, "/", (Route<dynamic> route) => route.isFirst);
          }),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: Style.horizontal(8)),
            height: Style.vertical(88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/login/send_email.svg",
                      width: Style.horizontal(75),
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: Style.horizontal(4)),
                        child: Text(
                          "${I18n.of(context).forgotPasswordSentText} ${authenticationState.formStatus.email}",
                          textAlign: TextAlign.center,
                          style: Style.titleSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Center(
                    child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          key: Key("reset_password_sent_button"),
                          textColor: Style.textButtonColorPrimary,
                          onPressed: () async {
                            if (authenticationState.isLogged.value) {
                              await authenticationState.signOut();
                            }
                            await Navigator.pushNamedAndRemoveUntil(context,
                                "/", (Route<dynamic> route) => route.isFirst);
                            AuthenticationState().cleanForm();
                          },
                          child: Text("OK"),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
