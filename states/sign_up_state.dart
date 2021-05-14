import 'package:flutter/material.dart';
import 'package:vimob/blocs/authentication/authentication_bloc.dart';
import 'package:vimob/blocs/authentication/input_validation_bloc.dart';
import 'package:vimob/models/user/form_status.dart';

class SignUpState with ChangeNotifier {
  factory SignUpState() => instance;

  static var instance = SignUpState._internal();
  SignUpState._internal();

  FormStatus signUpForm = FormStatus();

  cleanForm() {
    signUpForm = FormStatus();
    notifyListeners();
  }

  handleCpfValue({String newValue}) async {
    signUpForm.error = null;
    signUpForm.cpfValue = newValue;
    signUpForm.cpfIsValid =
        InputValidationBloc().validateCpfCnpj(value: newValue);
    signUpForm.isCheckingCpf = true;
    notifyListeners();

    if (newValue.length > 11) {
      signUpForm.cpfErrorText =
          await InputValidationBloc().verifyCpfUsed(newValue);
    }
    signUpForm.isCheckingCpf = false;
    notifyListeners();
  }

  handleEmailValue({String newValue}) async {
    signUpForm.error = null;
    signUpForm.email = newValue.toLowerCase();
    signUpForm.emailChanged = newValue.toLowerCase();
    signUpForm.emailIsValid =
        InputValidationBloc().validateEmail(email: signUpForm.email);
    signUpForm.isCheckingEmail = true;

    notifyListeners();
    if (signUpForm.emailIsValid) {
      signUpForm.emailErrorText =
          await InputValidationBloc().verifyEmailUsed(signUpForm.email);
      signUpForm.isCheckingEmail = false;
      notifyListeners();
    }
  }

  handleEmailChangedValue({String newValue}) async {
    signUpForm.error = null;
    signUpForm.emailChanged = newValue.toLowerCase();
    signUpForm.emailIsValid =
        InputValidationBloc().validateEmail(email: signUpForm.emailChanged);

    signUpForm.isCheckingEmail = true;
    notifyListeners();
    if (signUpForm.emailIsValid) {
      signUpForm.emailErrorText =
          await InputValidationBloc().verifyEmailUsed(signUpForm.emailChanged);
      signUpForm.isCheckingEmail = false;
      notifyListeners();
    }
  }

  handleNameValue({String newValue}) {
    signUpForm.error = null;
    signUpForm.nameIsValid =
        InputValidationBloc().validateEmptyField(value: newValue);

    signUpForm.name = newValue;

    notifyListeners();
  }

  handleLastNameValue({String newValue}) {
    signUpForm.error = null;
    signUpForm.lastNameIsValid =
        InputValidationBloc().validateEmptyField(value: newValue);

    signUpForm.lastName = newValue;

    notifyListeners();
  }

  handlePassword({String newValue}) {
    signUpForm.error = null;
    signUpForm.passwordIsValid =
        InputValidationBloc().validatePassword(passwordValue: newValue);

    signUpForm.passwordValue = newValue;
    notifyListeners();
  }

  handleRepeatPassword({String newValue}) {
    signUpForm.error = null;
    signUpForm.repeatPasswordValue = newValue;

    InputValidationBloc().validatePassword(passwordValue: newValue);
    notifyListeners();
  }

  comparePassword() {
    signUpForm.passwordIsEquals = InputValidationBloc().comparePassword(
        password: signUpForm.passwordValue,
        repeat: signUpForm.repeatPasswordValue);
    notifyListeners();
  }

  resendEmailConfirmation() async {
    signUpForm.inProgress = true;
    notifyListeners();
    signUpForm = await AuthenticationBloc().resendConfirmationEmail(signUpForm);
    notifyListeners();
  }

  signUp() async {
    try {
      signUpForm.inProgress = true;
      notifyListeners();

      signUpForm = await AuthenticationBloc().signUp(signUpForm);
      notifyListeners();
      if (signUpForm.error != null) {
        throw signUpForm.error;
      }
      // cleanForm();
    } catch (e) {
      throw e;
    }
  }
}
