import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/i18n/i18n.dart';
// import 'package:flutter_masked_text/flutter_masked_text.dart';
// import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/states/sign_up_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/cpf_text_field.dart';
import 'package:vimob/ui/authentication/email_confirmation_page.dart';
import 'package:vimob/ui/authentication/password_text_field.dart';
import 'package:vimob/ui/authentication/text_field_custom.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';
import 'package:vimob/utils/messages/translate_error_messages.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // var _nameController = FieldStatus();
  // var _lastNameController = FieldStatus();
  // var _cpfController =
  //     FieldStatus(textController: MaskedTextController(mask: '000.000.000-00'));
  // var _emailController = FieldStatus();
  // var _passwordController = FieldStatus();
  // var _confirmNewPasswordController = FieldStatus();

  @override
  Widget build(BuildContext context) {
    var signUpState = Provider.of<SignUpState>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBarResponsive().show(
        context: context,
        title: I18n.of(context).firstAccess,
      ),
      body: Container(
        height: Style.vertical(100),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  left: Style.horizontal(5),
                  right: Style.horizontal(5),
                  top: Style.vertical(3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: Style.vertical(2)),
                    child: Text(
                      I18n.of(context).signUp,
                      style: Style.mainTheme.appBarTheme.textTheme.headline6
                          .copyWith(
                              color: Color(0xFF6A6C7D),
                              fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: Style.vertical(3)),
                    child: Text(I18n.of(context).signUpText),
                  ),
                  TextFieldCustom(
                    fieldIsValid: signUpState.signUpForm.nameIsValid,
                    onChanged: (String newValue) {
                      signUpState.handleNameValue(newValue: newValue);
                    },
                    componentKey: Key("textfield_name"),
                    icon: Icon(
                      Icons.person,
                      color: Style.inputIconColor,
                      size: Style.inputIconSize,
                    ),
                    label: I18n.of(context).name,
                    textInputType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                  ),
                  TextFieldCustom(
                    fieldIsValid: signUpState.signUpForm.lastNameIsValid,
                    onChanged: (String newValue) {
                      signUpState.handleLastNameValue(newValue: newValue);
                    },
                    componentKey: Key("textfield_last_name"),
                    icon: Icon(
                      Icons.person,
                      color: Style.inputIconColor,
                      size: Style.inputIconSize,
                    ),
                    label: I18n.of(context).lastName,
                    textInputType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                  ),
                  CpfTextField(
                    formStatus: signUpState.signUpForm,
                    onChanged: (String newValue) {
                      signUpState.handleCpfValue(newValue: newValue);
                    },
                    helperText: signUpState.signUpForm.isCheckingCpf
                        ? I18n.of(context).checkingAvailability
                        : "",
                  ),
                  TextFieldCustom(
                    fieldIsValid: signUpState.signUpForm.emailIsValid,
                    onChanged: (String newValue) async {
                      await signUpState.handleEmailValue(newValue: newValue);
                    },
                    errorText: TranslateErrorMessages().translateEmailError(
                        error: signUpState.signUpForm.emailErrorText,
                        context: context),
                    componentKey: Key("textfield_email"),
                    icon: Icon(
                      Icons.email,
                      color: Style.inputIconColor,
                      size: Style.inputIconSize,
                    ),
                    label: I18n.of(context).email,
                    textInputType: TextInputType.emailAddress,
                    helperText: signUpState.signUpForm.isCheckingEmail
                        ? I18n.of(context).checkingAvailability
                        : null,
                  ),
                  PasswordTextField(
                    componentKey: Key("textfield_password"),
                    labelText: I18n.of(context).password,
                    helperText: I18n.of(context).minimumOfCharacters,
                    errorText: I18n.of(context).minimumOfCharacters,
                    fieldIsValid: signUpState.signUpForm.passwordIsValid,
                    formStatus: signUpState.signUpForm,
                    onChanged: (String newValue) {
                      signUpState.handlePassword(newValue: newValue);
                      signUpState.comparePassword();
                    },
                  ),
                  PasswordTextField(
                    componentKey: Key("textfield_password_repeat"),
                    labelText: I18n.of(context).confirmPassword,
                    helperText: I18n.of(context).minimumOfCharacters,
                    errorText: I18n.of(context).passwordDoesntMatch,
                    fieldIsValid: signUpState.signUpForm.passwordIsEquals,
                    formStatus: signUpState.signUpForm,
                    onChanged: (String newValue) {
                      signUpState.handleRepeatPassword(newValue: newValue);
                      signUpState.comparePassword();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: Style.vertical(3), bottom: Style.vertical(5)),
                    child: SizedBox(
                      width: double.infinity,
                      child: signUpState.signUpForm.inProgress
                          ? _buildLoadingButton()
                          : _buildSendEmailConfirmationButton(
                              signUpState, context),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSendEmailConfirmationButton(
      SignUpState signUpState, BuildContext context) {
    return RaisedButton(
      key: Key("send_email_button"),
      onPressed: () async {
        try {
          await signUpState.signUp();

          await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => EmailConfirmationPage(
                    email: signUpState.signUpForm.email,
                    formStatus: signUpState.signUpForm,
                  )));
        } catch (e) {
          if (signUpState.signUpForm.error != null) {
            ShowSnackbar().showSnackbarError(
                context,
                TranslateErrorMessages()
                    .translateError(error: e, context: context));
          }
        }
      },
      textColor: Style.textButtonColorPrimary,
      child: Text(
        I18n.of(context).send.toUpperCase(),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return RaisedButton(
      textColor: Colors.white,
      onPressed: () {},
      child: SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(
            valueColor: Style.loadingColor,
          )),
    );
  }
}
