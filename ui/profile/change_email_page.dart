import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/authentication/input_validation_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/profile_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/email_confirmation_page.dart';
import 'package:vimob/ui/authentication/password_text_field.dart';
import 'package:vimob/ui/authentication/text_field_custom.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';
import 'package:vimob/utils/messages/translate_error_messages.dart';
import 'package:vimob/utils/widgets/loading_raised_button.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({Key key}) : super(key: key);

  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  var _emailController = FieldStatus();
  var _passwordController = FieldStatus();
  var _formStatus = FormStatus();

  @override
  void initState() {
    super.initState();
    _emailController.controller = TextEditingController();
    _passwordController.controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthenticationState>(context).user;
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBarResponsive()
          .show(context: context, title: I18n.of(context).changeEmail),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            height: Style.vertical(88),
            padding: EdgeInsets.symmetric(
                vertical: Style.horizontal(5), horizontal: Style.horizontal(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Style.horizontal(4)),
                  child: Text(
                    I18n.of(context).changeEmailTitle,
                    style: Style.titleSecondaryText,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Style.horizontal(4)),
                  child: Text(I18n.of(context).changeEmailText),
                ),
                //=========================== New email ===========================

                TextFieldCustom(
                  componentKey: Key("new_email_textfield"),
                  controller: _emailController.controller,
                  label: I18n.of(context).newEmail,
                  icon: Icon(
                    Icons.email,
                    color: Style.inputIconColor,
                    size: Style.inputIconSize,
                  ),
                  fieldIsValid: _emailController.isValid,
                  errorText: _emailController.errorText,
                  textInputType: TextInputType.emailAddress,
                  helperText: FormStatus().isCheckingEmail
                      ? I18n.of(context).checkingAvailability
                      : null,
                  onChanged: (String newValue) {
                    setState(() {
                      _emailController.controller.value = _emailController
                          .controller.value
                          .copyWith(text: newValue);

                      _emailController.isValid =
                          InputValidationBloc().validateEmail(email: newValue);
                    });
                  },
                ),
                //=========================== Password ===========================

                PasswordTextField(
                    componentKey: Key("password_textfield"),
                    formStatus: FormStatus(),
                    onChanged: (String newValue) {
                      setState(() {
                        _passwordController.controller.value =
                            _passwordController.controller.value
                                .copyWith(text: newValue);

                        _passwordController.isValid = InputValidationBloc()
                            .validatePassword(passwordValue: newValue);
                      });
                    },
                    errorText: I18n.of(context).passwordInvalid,
                    fieldIsValid: _passwordController.isValid,
                    labelText: I18n.of(context).password),
                Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: _formStatus.inProgress
                      ? LoadingRaisedButton()
                      : RaisedButton(
                          key: Key("change_email_send_button"),
                          textColor: Style.textButtonColorPrimary,
                          onPressed: () async {
                            try {
                              await _updateEmail(user, context);
                            } catch (e) {
                              String _err = _defineErrorType(e);

                              ShowSnackbar().showSnackbarError(
                                  context,
                                  TranslateErrorMessages().translateError(
                                      context: context, error: _err));
                              setState(() {
                                _formStatus.inProgress = false;
                              });
                            }
                          },
                          child: Text(I18n.of(context).send.toUpperCase()),
                        ),
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _updateEmail(User user, BuildContext context) async {
    setState(() {
      _formStatus.inProgress = true;
    });

    _validateAllFields();

    if (_emailController.isValid && _passwordController.isValid) {
      await ProfileState().updateUserEmail(
          user: user,
          newEmail: _emailController,
          password: _passwordController);

      await AuthenticationState().signOut();

      await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => EmailConfirmationPage(
                email: _emailController.controller.text,
                formStatus: FormStatus()
                  ..email = _emailController.controller.text
                  ..emailChanged = _emailController.controller.text,
              )));
    } else {
      throw "FIELDS_REQUIRED";
    }
  }

  String _defineErrorType(e) {
    String err;
    if (e.runtimeType == String) {
      err = e;
    } else {
      err = e.code;
    }
    return err;
  }

  void _validateAllFields() {
    setState(() {
      _emailController.isValid = InputValidationBloc()
          .validateEmail(email: _emailController.controller.text);

      _passwordController.isValid = InputValidationBloc()
          .validatePassword(passwordValue: _passwordController.controller.text);
    });
  }
}
