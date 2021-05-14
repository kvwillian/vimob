import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/states/sign_up_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/cpf_text_field.dart';
import 'package:vimob/ui/authentication/email_confirmation_page.dart';
import 'package:vimob/ui/authentication/password_text_field.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';
import 'package:vimob/utils/messages/translate_error_messages.dart';
import 'package:vimob/utils/widgets/loading_raised_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key key,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode passwordFocusNode;

  void initState() {
    super.initState();
    passwordFocusNode = FocusNode();
    passwordFocusNode.addListener(() {});
  }

  @override
  void dispose() {
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var authenticationState = Provider.of<AuthenticationState>(context);
    var connectivityState = Provider.of<ConnectivityState>(context);

    return Stack(
      children: <Widget>[
        _buildBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Container(
                  height: Style.vertical(100),
                  width: Style.horizontal(100),
                  color: Colors.transparent,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: Style.horizontal(40),
                      ),
                      Center(
                        child: Container(
                          color: Colors.white,
                          // height: Style.horizontal(90),
                          width: Style.horizontal(80),
                          child: Column(
                            children: <Widget>[
                              Container(
                                color: Style.brandColor,
                                height: Style.vertical(10),
                                child: _buildLogo(),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: Style.horizontal(7),
                                  right: Style.horizontal(7),
                                  top: Style.horizontal(5),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    CpfTextField(
                                      formStatus:
                                          authenticationState.formStatus,
                                      onChanged: (String newValue) {
                                        authenticationState.handleCpfValue(
                                            newValue: newValue);
                                      },
                                      onEditingComplete: () {
                                        if (authenticationState
                                            .formStatus.cpfIsValid) {
                                          FocusScope.of(context)
                                              .requestFocus(passwordFocusNode);
                                        }
                                      },
                                    ),
                                    PasswordTextField(
                                      componentKey: Key("textfield_password"),
                                      labelText: I18n.of(context).password,
                                      helperText: "",
                                      passwordFocusNode: passwordFocusNode,
                                      onChanged: (String newValue) {
                                        authenticationState.handlePassword(
                                            newValue: newValue);
                                      },
                                      fieldIsValid: authenticationState
                                          .formStatus.passwordIsValid,
                                      formStatus:
                                          authenticationState.formStatus,
                                    ),
                                    Container(
                                      width: double.maxFinite,
                                      margin: EdgeInsets.only(
                                          bottom: Style.horizontal(3)),
                                      child: authenticationState
                                              .formStatus.inProgress
                                          ? LoadingRaisedButton()
                                          : _buildLoginButton(
                                              authenticationState,
                                              connectivityState),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(
                                            bottom: Style.horizontal(5)),
                                        width: double.maxFinite,
                                        child: _buildSignUpButton(context)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: _buildForgotPasswordButton(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InkWell _buildForgotPasswordButton(BuildContext context) {
    return InkWell(
      key: Key("forgot_password_button"),
      onTap: () {
        Navigator.pushNamed(context, 'forgotPassword');
      },
      child: Text(
        I18n.of(context).forgotPassword,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  Center _buildBackground() {
    return Center(
      child: Image.asset(
        "assets/login/app_login_background.jpg",
        height: Style.vertical(100),
        width: Style.horizontal(100),
        fit: BoxFit.fill,
      ),
    );
  }

  Center _buildLogo() {
    return Center(
      child: SvgPicture.asset(
        "assets/login/vimob.svg",
        height: Style.vertical(5),
      ),
    );
  }

  Widget _buildLoginButton(AuthenticationState authenticationState,
      ConnectivityState connectivityState) {
    return RaisedButton(
      key: Key("btn_sign_in"),
      padding: EdgeInsets.all(0),
      textColor: Style.textButtonColorPrimary,
      onPressed: () async {
        if (connectivityState.hasInternet) {
          try {
            await authenticationState.signIn();
          } catch (e) {
            if (authenticationState.formStatus.error != null) {
              ShowSnackbar().showSnackbarError(
                  context,
                  TranslateErrorMessages().translateError(
                      error: authenticationState.formStatus.error,
                      context: context));
              if (e == "ERROR_EMAIL_CONFIRMATION") {
                SignUpState().signUpForm = authenticationState.formStatus
                  ..email = authenticationState.user.email
                  ..emailChanged = authenticationState.user.email
                  ..cpfIsValid = true;
                await SignUpState().resendEmailConfirmation();

                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EmailConfirmationPage(
                              email: authenticationState.user.email,
                              formStatus: authenticationState.formStatus,
                              isUnconfirmed: true,
                            )));
              }
            }
          }
        } else {
          ShowSnackbar()
              .showSnackbarError(context, I18n.of(context).checkConnection);
        }
      },
      child: Text(I18n.of(context).login.toUpperCase()),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return OutlineButton(
      key: Key("login_sign_up_button"),
      padding: EdgeInsets.all(0),
      textColor: Style.textButtonColorSecondary,
      onPressed: () {
        Navigator.pushNamed(context, 'signUp');
      },
      child: Text(I18n.of(context).firstAccess.toUpperCase()),
    );
  }
}
