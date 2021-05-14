import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vimob/blocs/authentication/input_validation_bloc.dart';
import 'package:vimob/i18n/i18n.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/profile_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/password_text_field.dart';
import 'package:vimob/ui/common/app_bar_responsive.dart';
import 'package:vimob/utils/messages/show_snack_bar.dart';
import 'package:vimob/utils/messages/translate_error_messages.dart';
import 'package:vimob/utils/widgets/loading_raised_button.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage({Key key}) : super(key: key);

  @override
  ChangePasswordPageState createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  var _passwordController = FieldStatus();
  var _newPasswordController = FieldStatus();
  var _confirmNewPasswordController = FieldStatus();

  @override
  void initState() {
    super.initState();
    _passwordController.controller = TextEditingController();
    _newPasswordController.controller = TextEditingController();
    _confirmNewPasswordController.controller = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.controller.dispose();
    _newPasswordController.controller.dispose();
    _confirmNewPasswordController.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var profileState = Provider.of<ProfileState>(context);
    var user = Provider.of<AuthenticationState>(context).user;

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBarResponsive()
          .show(context: context, title: I18n.of(context).changePassword),
      body: Container(
        height: Style.vertical(88),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Style.horizontal(5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: Style.horizontal(8), bottom: Style.horizontal(5)),
                    child: Text(
                      I18n.of(context).changePasswordTitle,
                      style: Style.titleSecondaryText,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: Style.horizontal(8)),
                    child: Text(
                      I18n.of(context).changePasswordText,
                    ),
                  ),
                  //===========================Current password===========================
                  Padding(
                    padding: EdgeInsets.only(bottom: Style.horizontal(5)),
                    child: PasswordTextField(
                        componentKey: Key("current_password_textfield"),
                        formStatus: profileState.profileForm,
                        controller: _passwordController.controller,
                        onChanged: (String newValue) => setState(() {
                              _passwordController.controller.value =
                                  _passwordController.controller.value
                                      .copyWith(text: newValue);

                              _passwordController.isValid =
                                  InputValidationBloc().validatePassword(
                                      passwordValue: newValue);
                            }),
                        helperText: "",
                        fieldIsValid: _passwordController.isValid,
                        labelText: I18n.of(context).currentPassword),
                  ),
                  //===========================New password===========================
                  PasswordTextField(
                    componentKey: Key("new_password_textfield"),
                    controller: _newPasswordController.controller,
                    labelText: I18n.of(context).newPassword,
                    helperText: I18n.of(context).minimumOfCharacters,
                    errorText: I18n.of(context).minimumOfCharacters,
                    fieldIsValid: _newPasswordController.isValid,
                    formStatus: profileState.profileForm,
                    onChanged: (String newValue) => _validateField(
                        newValue: newValue,
                        fieldStatus: _newPasswordController),
                  ),
                  //===========================Repeat new password===========================
                  PasswordTextField(
                    componentKey: Key("repeat_password_textfield"),
                    controller: _confirmNewPasswordController.controller,
                    labelText: I18n.of(context).confirmPassword,
                    helperText: I18n.of(context).minimumOfCharacters,
                    errorText: I18n.of(context).passwordDoesntMatch,
                    fieldIsValid: _confirmNewPasswordController.isValid,
                    formStatus: profileState.profileForm,
                    onChanged: (String newValue) => _validateField(
                        newValue: newValue,
                        fieldStatus: _confirmNewPasswordController),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: Style.horizontal(8),
                        horizontal: Style.horizontal(2)),
                    child: InkWell(
                      onTap: () =>
                          Navigator.of(context).pushNamed("forgotPassword"),
                      child: Text(
                        I18n.of(context).forgotPassword,
                        style: Style.textHighlightBold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: profileState.profileForm.inProgress
                        ? LoadingRaisedButton()
                        : RaisedButton(
                            key: Key("change_password_send_button"),
                            textColor: Style.textButtonColorPrimary,
                            onPressed: () async {
                              try {
                                _validateAllFields();

                                await profileState.updateUserPassword(
                                    email: user.email,
                                    newPassword: _newPasswordController,
                                    oldPassword: _passwordController,
                                    repeatNewPassword:
                                        _confirmNewPasswordController);

                                ShowSnackbar().showSnackbarSuccess(
                                    context, I18n.of(context).success);
                              } catch (e) {
                                String err = _defineErrorType(e);

                                ShowSnackbar().showSnackbarError(
                                    context,
                                    TranslateErrorMessages().translateError(
                                        context: context, error: err));
                              }
                            },
                            child: Text(I18n.of(context).save.toUpperCase()),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateField(
      {@required String newValue, @required FieldStatus fieldStatus}) {
    setState(() {
      fieldStatus.controller.value =
          fieldStatus.controller.value.copyWith(text: newValue);
      fieldStatus.isValid =
          InputValidationBloc().validatePassword(passwordValue: newValue);

      _confirmNewPasswordController.isValid = InputValidationBloc()
          .comparePassword(
              password: _newPasswordController.controller.text,
              repeat: _confirmNewPasswordController.controller.text);
    });
  }

  //Check if error is a string or a PlataformException
  String _defineErrorType(e) {
    String err;
    if (e.runtimeType != String) {
      err = e.code;
    } else {
      err = e;
    }
    return err;
  }

  void _validateAllFields() {
    setState(() {
      _passwordController.isValid = InputValidationBloc()
          .validatePassword(passwordValue: _passwordController.controller.text);

      _newPasswordController.isValid = InputValidationBloc().validatePassword(
          passwordValue: _newPasswordController.controller.text);

      _confirmNewPasswordController.isValid = InputValidationBloc()
          .comparePassword(
              password: _newPasswordController.controller.text,
              repeat: _confirmNewPasswordController.controller.text);
    });
  }
}
