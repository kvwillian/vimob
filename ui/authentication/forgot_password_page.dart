import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/cpf_text_field.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';
import 'package:vimob/utils/messages/translate_error_messages.dart';
import 'package:vimob/utils/widgets/loading_raised_button.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authenticationState = Provider.of<AuthenticationState>(context);
    var connectivityState = Provider.of<ConnectivityState>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBarResponsive().show(
          context: context,
          title: I18n.of(context).validateYourEmail,
          onBack: () {
            if (AuthenticationState().isLogged.value) {
              Navigator.of(context).pop();
            } else {
              AuthenticationState().cleanForm();
              Navigator.pushNamedAndRemoveUntil(
                  context, "/", (Route<dynamic> route) => route.isFirst);
            }
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
                          I18n.of(context).forgotPasswordText,
                          style: Style.titleSecondaryText,
                        ),
                      ),
                      CpfTextField(
                        formStatus: authenticationState.formStatus,
                        onChanged: (String newValue) {
                          authenticationState.handleCpfValue(
                              newValue: newValue);
                        },
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: authenticationState.formStatus.inProgress
                          ? LoadingRaisedButton()
                          : RaisedButton(
                              key: Key("send_reset_password_button"),
                              textColor: Style.textButtonColorPrimary,
                              onPressed: () async {
                                if (connectivityState.hasInternet) {
                                  await AuthenticationState().forgotPassword(
                                      cpf:
                                          authenticationState.formStatus.email);
                                  if (authenticationState.formStatus.error !=
                                      null) {
                                    ShowSnackbar().showSnackbarError(
                                        context,
                                        TranslateErrorMessages().translateError(
                                            context: context,
                                            error: authenticationState
                                                .formStatus.error));
                                  } else {
                                    Navigator.pushNamed(
                                        context, "forgotPasswordSent");
                                  }
                                } else {
                                  ShowSnackbar().showSnackbarError(context,
                                      I18n.of(context).checkConnection);
                                }
                              },
                              child: Text(I18n.of(context).send.toUpperCase()),
                            ),
                    ),
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
