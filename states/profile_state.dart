import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/material.dart';
import 'package:vimob/blocs/authentication/authentication_bloc.dart';
import 'package:vimob/blocs/authentication/input_validation_bloc.dart';
import 'package:vimob/blocs/user/user_bloc.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/authentication_state.dart';

class ProfileState with ChangeNotifier {
  factory ProfileState() => instance;
  static var instance = ProfileState._internal();
  ProfileState._internal();

  StreamSubscription _listnerUploadTask;
  storage.TaskState storageTaskEventType;

  updateImageProfile({File image, User user}) {
    if (_listnerUploadTask != null) {
      _listnerUploadTask.cancel();
    }

    _listnerUploadTask = UserBloc()
        .uploadProfileImage(image: image, uid: user.uid)
        .snapshotEvents
        .listen((task) async {
      if (storageTaskEventType != task.state) {
        storageTaskEventType = task.state;
        print(task.state);
        notifyListeners();
        if (task.state == storage.TaskState.success) {
          await UserBloc().updateProfileImage(
              imageUrl: await task.ref.getDownloadURL(), uid: user.uid);

          user = await UserBloc().fetchUserInformationByUid(uid: user.uid);
          print("Success");
          notifyListeners();
        }
      }
    });
  }

  FormStatus profileForm = FormStatus();

  handleNameValue({String newValue}) {
    profileForm.error = null;
    profileForm.nameIsValid =
        InputValidationBloc().validateEmptyField(value: newValue);

    profileForm.name = newValue;

    notifyListeners();
  }

  handleLastNameValue({String newValue}) {
    profileForm.error = null;
    profileForm.lastNameIsValid =
        InputValidationBloc().validateEmptyField(value: newValue);

    profileForm.lastName = newValue;

    notifyListeners();
  }

  handlePhoneValue({String newValue}) {
    profileForm.error = null;
    // profileForm.phoneIsValid =
    //     InputValidationBloc().validateEmptyField(value: newValue);

    profileForm.phoneValue = newValue;

    notifyListeners();
  }

  handlePassword({String newValue}) {
    profileForm.error = null;
    profileForm.passwordIsValid =
        InputValidationBloc().validatePassword(passwordValue: newValue);

    notifyListeners();
  }

  comparePassword(
      {@required String newPassword, @required String repeatPassword}) {
    profileForm.passwordIsEquals = InputValidationBloc()
        .comparePassword(password: newPassword, repeat: repeatPassword);
    notifyListeners();
  }

  updateUserInformation({User user}) async {
    profileForm.nameIsValid =
        InputValidationBloc().validateEmptyField(value: profileForm.name);
    profileForm.lastNameIsValid =
        InputValidationBloc().validateEmptyField(value: profileForm.lastName);

    if (profileForm.nameIsValid &&
        profileForm.lastNameIsValid &&
        profileForm.emailErrorText == null) {
      var userData = User()
        ..uid = user.uid
        ..name = profileForm.name
        ..lastName = profileForm.lastName
        ..phone = profileForm.phoneValue
        ..email = user.email;

      await UserBloc().updateUserInformation(user: userData);
      AuthenticationState().user =
          await UserBloc().fetchUserInformationByUid(uid: user.uid);
      notifyListeners();
    } else {
      profileForm.error = "FIELDS_REQUIRED";
      notifyListeners();
      throw Exception("FIELDS_REQUIRED");
    }
  }

  updateUserPassword(
      {@required String email,
      @required FieldStatus oldPassword,
      @required FieldStatus newPassword,
      @required FieldStatus repeatNewPassword}) async {
    try {
      profileForm.inProgress = true;
      notifyListeners();

      if (oldPassword.isValid &&
          newPassword.isValid &&
          repeatNewPassword.isValid) {
        await AuthenticationBloc().reauthentication(
            email: email, password: oldPassword.controller.text);
        await AuthenticationBloc()
            .updatePassword(newPassword: repeatNewPassword.controller.text);
      } else {
        profileForm.passwordIsValid = false;
        notifyListeners();
        throw "FIELDS_REQUIRED";
      }

      profileForm.inProgress = false;
      notifyListeners();
    } catch (e) {
      profileForm.inProgress = false;
      notifyListeners();
      throw e;
    }
    notifyListeners();
  }

  updateUserEmail(
      {@required User user,
      @required FieldStatus newEmail,
      @required FieldStatus password}) async {
    try {
      await AuthenticationBloc().reauthentication(
          email: user.email, password: password.controller.text);
      await AuthenticationBloc()
          .updateUserEmail(newEmail: newEmail.controller.text);
      await UserBloc()
          .updateUserInformation(user: user..email = newEmail.controller.text);

      await AuthenticationBloc().waitEmailConfirmation(
          email: user.email, password: password.controller.text);
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }
}
