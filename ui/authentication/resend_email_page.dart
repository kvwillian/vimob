import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/authentication/authentication_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/sign_up_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/text_field_custom.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';
import 'package:vimob/utils/messages/translate_error_messages.dart';

class ReSendEmailPage extends StatelessWidget {
  ReSendEmailPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var signUpState = Provider.of<SignUpState>(context);
    var authenticationState = Provider.of<AuthenticationState>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBarResponsive().show(
          context: context,
          title: I18n.of(context).validateYourEmail,
          onBack: () {
            AuthenticationBloc().waitEmailConfirmation(
                email: signUpState.signUpForm.email ??
                    authenticationState.formStatus.email,
                password: signUpState.signUpForm.passwordValue ??
                    authenticationState.formStatus.passwordValue);
            Navigator.pop(context);
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
                  flex: 2,
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/login/send_email.svg",
                      width: Style.horizontal(75),
                    ),
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: Style.horizontal(4)),
                        child: Text(
                          I18n.of(context).enterNewEmail,
                          style: Style.titleSecondaryText,
                        ),
                      ),
                      TextFieldCustom(
                        fieldIsValid: signUpState.signUpForm.emailIsValid,
                        onChanged: (String newValue) {
                          signUpState.handleEmailChangedValue(
                              newValue: newValue);
                        },
                        errorText: TranslateErrorMessages().translateEmailError(
                            context: context,
                            error: signUpState.signUpForm.emailErrorText),
                        componentKey: Key("text_field_email"),
                        icon: Icon(
                          Icons.email,
                          color: Style.inputIconColor,
                          size: Style.vertical(3),
                        ),
                        label: I18n.of(context).email,
                        textInputType: TextInputType.emailAddress,
                        helperText: signUpState.signUpForm.isCheckingEmail
                            ? I18n.of(context).checkingAvailability
                            : null,
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Flexible(
                  child: Center(
                    child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          textColor: Style.textButtonColorPrimary,
                          onPressed: () async {
                            try {
                              authenticationState.formStatus =
                                  signUpState.signUpForm;

                              authenticationState.changeEmail();

                              if (signUpState.signUpForm.error != null) {
                                ShowSnackbar().showSnackbarError(
                                    context, signUpState.signUpForm.error);
                              } else {
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Text(I18n.of(context).send.toUpperCase()),
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
