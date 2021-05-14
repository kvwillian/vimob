import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vimob/blocs/authentication/authentication_bloc.dart';
import 'package:vimob/blocs/authentication/input_validation_bloc.dart';
import 'package:vimob/blocs/notification/notification_bloc.dart';
import 'package:vimob/blocs/user/user_bloc.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/models/user/form_status.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/buyer_state.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/states/sign_up_state.dart';

class AuthenticationState with ChangeNotifier {
  factory AuthenticationState() => instance;
  static var instance = AuthenticationState._internal();
  AuthenticationState._internal();

  FormStatus formStatus = FormStatus();

  var user = User();

  StreamSubscription _listnerUploadTask;
  storage.TaskState storageTaskEventType;

  updateImageProfile({File image}) {
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
              imageUrl: await task.ref.getDownloadURL(),
              uid: user.uid,
              file: image);

          user = await UserBloc().fetchUserInformationByUid(uid: user.uid);
          print("Success");
          notifyListeners();
        }
      }
    });
  }

  var isLogged = BehaviorSubject<bool>()..add(true);

  cleanForm() {
    formStatus = FormStatus();
    notifyListeners();
  }

  handleCpfValue({String newValue}) {
    formStatus.error = null;
    formStatus.cpfErrorText = null;

    formStatus.cpfIsValid =
        InputValidationBloc().validateCpfCnpj(value: newValue);
    formStatus.passwordIsValid =
        InputValidationBloc().validatePassword(passwordValue: newValue);

    formStatus.cpfValue = newValue;

    notifyListeners();
  }

  handlePassword({String newValue}) {
    formStatus.error = null;
    formStatus.cpfErrorText = null;
    formStatus.cpfIsValid =
        InputValidationBloc().validateCpfCnpj(value: formStatus.cpfValue);
    formStatus.passwordIsValid =
        InputValidationBloc().validatePassword(passwordValue: newValue);

    formStatus.passwordValue = newValue;
    notifyListeners();
  }

  final auth.FirebaseAuth authentication = auth.FirebaseAuth.instance;
  StreamSubscription _loginListener;

  checkLogin({Locale locale, BuildContext context}) async {
    if (_loginListener != null) {
      await _loginListener.cancel();
    }
    _loginListener =
        authentication.authStateChanges().listen((firebaseUser) async {
      String uid;
      if (firebaseUser == null || !firebaseUser.emailVerified) {
        //redirect to login_page
        isLogged.add(false);
        formStatus.error = "ERROR_EMAIL_CONFIRMATION";
        notifyListeners();
      } else {
        //redirect to home_page
        if (ConnectivityState().hasInternet) {
          var idToken = await firebaseUser.getIdToken(true);
          print("CheckUser: " + idToken);
        }

        uid = firebaseUser.uid;
        formStatus.error = null;

        //Initial fetch
        await fetchUser(uid: uid);
        if (user.company != null) {
          //TODO: only portuguese
          // if (locale.languageCode != user.language) {
          // UserBloc().upadateUserLanguage(user, locale);
          // }

          await getUserPermissions();

          await CompanyState().fetchCompanyStatuses(companyId: user.company);

          await CompanyState().fetchCompanyUrlMap(companyId: user.company);

          await ProposalState()
              .fetchPropsalsList(companyId: user.company, uid: user.uid);

          await BuyerState().fetchBuyers(
              companyId: user.company,
              uid: user.uid,
              userExternalId: user.companies[user.company].externalId);

          await NotificationBloc()
              .configFirebaseCloudMessaging(user: user, context: context);
        }
        String fcmToken = await NotificationBloc().getTokenFcm();
        if (user.fcmToken != fcmToken) {
          UserBloc().updateUserFcmToken(user, fcmToken);
        }

        isLogged.add(true);
      }
    });
  }

  signOut() async {
    AuthenticationState().cleanForm();
    DevelopmentState().cleanStream();
    await UserBloc().updateUserFcmToken(user, null);
    user = User();
    notifyListeners();
    await auth.FirebaseAuth.instance.signOut();
  }

  forgotPassword({String cpf}) async {
    formStatus.inProgress = true;

    User user =
        await UserBloc().fetchUserInformationByCpf(cpf: formStatus.cpfValue);

    if (user.email != null) {
      formStatus.email = user.email;
      notifyListeners();

      await AuthenticationBloc().resetPassword(email: user.email);
    } else {
      formStatus.error = "ERROR_USER_NOT_FOUND";
      notifyListeners();
    }
    formStatus.inProgress = false;
    notifyListeners();
  }

  signIn() async {
    try {
      formStatus.inProgress = true;
      notifyListeners();

      //checking if the fields are correct
      formStatus.passwordIsValid = InputValidationBloc()
          .validatePassword(passwordValue: formStatus.passwordValue);
      formStatus.cpfIsValid =
          InputValidationBloc().validateCpfCnpj(value: formStatus.cpfValue);

      user =
          await UserBloc().fetchUserInformationByCpf(cpf: formStatus.cpfValue);

      if (user.email != null) {
        formStatus = await AuthenticationBloc()
            .login(loginStatus: formStatus, userEmail: user.email);

        checkLogin();
      } else {
        formStatus.error = "ERROR_USER_NOT_FOUND";
        formStatus.cpfErrorText = "";
        formStatus.inProgress = false;
        throw formStatus.error;
      }

      notifyListeners();

      if (formStatus.error != null) {
        throw formStatus.error;
      }
    } catch (e) {
      print(e.toString());
      formStatus.inProgress = false;
      notifyListeners();
      throw e;
    }
  }

  changeEmail() async {
    try {
      formStatus.inProgress = true;
      notifyListeners();

      formStatus = await AuthenticationBloc().loginWithoutConfirmation(
          loginStatus: formStatus, userEmail: formStatus.email);

      notifyListeners();

      await AuthenticationBloc()
          .updateUserEmail(newEmail: SignUpState().signUpForm.emailChanged);

      formStatus = await AuthenticationBloc().loginWithoutConfirmation(
          loginStatus: formStatus, userEmail: formStatus.emailChanged);

      user =
          await UserBloc().fetchUserInformationByCpf(cpf: formStatus.cpfValue);

      notifyListeners();

      await UserBloc().updateUserInformation(
          user: user..email = SignUpState().signUpForm.emailChanged);
      await AuthenticationBloc().waitEmailConfirmation(
          email: SignUpState().signUpForm.emailChanged,
          password: SignUpState().signUpForm.passwordValue);

      if (formStatus.error != null) {
        throw formStatus.error;
      }
    } catch (e) {
      print(e.body);
      formStatus.inProgress = false;
      notifyListeners();
      throw e;
    }
  }

  updateSelectedCompany(Company company) async {
    user.company = company.id;
    user.companyName = company.name;
    notifyListeners();
    await UserBloc().updateSelectedCompany(user);

    ProposalState().fetchPropsalsList(companyId: user.company, uid: user.uid);

    await BuyerState().fetchBuyers(
        companyId: user.company,
        uid: user.uid,
        userExternalId: user.companies[user.company].externalId);

    DevelopmentState()
        .fetchDevelopments(companyId: user.company, uid: user.uid);
  }

  fetchUser({String uid}) async {
    user = await UserBloc().fetchUserInformationByUid(uid: uid);
    notifyListeners();
  }

  getUserPermissions() async {
    String permissionId = user.companies.values
        .firstWhere((c) => c.id == user.company)
        .permissionId;

    UserBloc()
        .fetchUserPermissions(permissionId)
        .listen((userPermissionsSnapshot) {
      user.userPermissions = userPermissionsSnapshot;
      notifyListeners();
    });
  }

  void updateFirstAccess(String uid) {
    user.firstAccess = false;
    notifyListeners();

    AuthenticationBloc().updateFirstAccess(uid);
  }
}
