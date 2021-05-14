import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:vimob/blocs/authentication/input_validation_bloc.dart';
import 'package:vimob/models/user/form_status.dart';

class AuthenticationBloc {
  factory AuthenticationBloc() => instance;
  AuthenticationBloc._internal();
  static var instance = AuthenticationBloc._internal();

  Future<FormStatus> login({FormStatus loginStatus, String userEmail}) async {
    if (loginStatus.passwordIsValid && loginStatus.cpfIsValid) {
      try {
        //Try sign in
        loginStatus.error = null;
        var firebaseUser = await auth.FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: userEmail, password: loginStatus.passwordValue);

        loginStatus.inProgress = false;
        if (!firebaseUser.user.emailVerified) {
          throw "ERROR_EMAIL_CONFIRMATION";
        }
        return loginStatus;
      } catch (e) {
        loginStatus.passwordIsValid = false;
        loginStatus.cpfIsValid = false;
        loginStatus.inProgress = false;
        loginStatus.cpfErrorText = "";
        loginStatus.error = e.runtimeType != String ? e.code : e;
        print(e);
        return loginStatus;
      }
    } else {
      loginStatus.inProgress = false;
      loginStatus.error = "CPF e/ou senha estão invalidos";
      return loginStatus;
    }
  }

  //fix email confirmation isn't necessary in react version
  Future<FormStatus> loginWithoutConfirmation(
      {FormStatus loginStatus, String userEmail}) async {
    try {
      //Try sign in
      loginStatus.error = null;
      await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userEmail, password: loginStatus.passwordValue);

      loginStatus.inProgress = false;

      return loginStatus;
    } catch (e) {
      loginStatus.passwordIsValid = false;
      loginStatus.cpfIsValid = false;
      loginStatus.inProgress = false;
      loginStatus.cpfErrorText = "";
      loginStatus.error = e.runtimeType != String ? e.code : e;
      print(e);
      return loginStatus;
    }
  }

  Future<FormStatus> signUp(FormStatus signUpForm) async {
    //Check if change the email to confirmation
    if (signUpForm.emailChanged != "") {
      signUpForm.email = signUpForm.emailChanged;
    }

    //checking if the fields are correct

    signUpForm.emailIsValid =
        InputValidationBloc().validateEmail(email: signUpForm.email);
    signUpForm.cpfIsValid =
        InputValidationBloc().validateCpfCnpj(value: signUpForm.cpfValue);
    signUpForm.nameIsValid =
        InputValidationBloc().validateEmptyField(value: signUpForm.name);
    signUpForm.lastNameIsValid =
        InputValidationBloc().validateEmptyField(value: signUpForm.lastName);
    signUpForm.passwordIsValid = InputValidationBloc()
        .validatePassword(passwordValue: signUpForm.passwordValue);
    signUpForm.emailErrorText =
        await InputValidationBloc().verifyEmailUsed(signUpForm.email);
    signUpForm.cpfErrorText =
        await InputValidationBloc().verifyCpfUsed(signUpForm.cpfValue);

    signUpForm.passwordIsEquals = InputValidationBloc().comparePassword(
        password: signUpForm.passwordValue,
        repeat: signUpForm.repeatPasswordValue);

    if (signUpForm.emailErrorText == null &&
        signUpForm.cpfErrorText == null &&
        signUpForm.cpfIsValid &&
        signUpForm.emailIsValid &&
        signUpForm.nameIsValid &&
        signUpForm.lastNameIsValid &&
        signUpForm.passwordIsEquals) {
      try {
        //Create user
        var authResult = await auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: signUpForm.email, password: signUpForm.passwordValue);

        //Send email
        await authResult.user.sendEmailVerification();

        //Create user in Firestore
        await createUserFirestore(
          signUpForm,
          authResult.user.uid,
        );

        //wait email confirmation to redirect page
        await waitEmailConfirmation(
            email: signUpForm.email, password: signUpForm.passwordValue);

        signUpForm.inProgress = false;
        signUpForm.error = null;
      } catch (e) {
        signUpForm.inProgress = false;
        signUpForm.error = e.code;

        return signUpForm;
      }
    } else {
      signUpForm.inProgress = false;
      signUpForm.error = "FIELDS_REQUIRED";
      print("emailErrorText: ${signUpForm.emailErrorText}");
      print("cpfErrorText: ${signUpForm.cpfErrorText}");
      print("cpfIsValid: ${signUpForm.cpfIsValid}");
      print("emailIsValid: ${signUpForm.emailIsValid}");
      print("nameIsValid: ${signUpForm.nameIsValid}");
      print("lastNameIsValid: ${signUpForm.lastNameIsValid}");
      print("passwordIsEquals: ${signUpForm.passwordIsEquals}");
    }

    return signUpForm;
  }

  Future<FormStatus> resendConfirmationEmail(FormStatus signUpForm) async {
    signUpForm.emailIsValid =
        InputValidationBloc().validateEmail(email: signUpForm.email);

    if (signUpForm.cpfIsValid &&
        signUpForm.emailIsValid &&
        signUpForm.nameIsValid &&
        signUpForm.lastNameIsValid &&
        signUpForm.passwordIsEquals) {
      try {
        //Create user
        var user = auth.FirebaseAuth.instance.currentUser;

        //Send email
        await user.sendEmailVerification();
        //Redirect when confirm email
        await waitEmailConfirmation(
            email: signUpForm.email, password: signUpForm.passwordValue);

        signUpForm.inProgress = false;
        signUpForm.error = null;
      } catch (e) {
        signUpForm.inProgress = false;
        signUpForm.error = "Opa! Ocorreu um erro. Tente novamente";

        return signUpForm;
      }
    } else {
      signUpForm.inProgress = false;
      signUpForm.error = "Preencher o campo corretamente";
      print("cpfIsValid: ${signUpForm.cpfIsValid}");
      print("emailIsValid: ${signUpForm.emailIsValid}");
      print("nameIsValid: ${signUpForm.nameIsValid}");
      print("lastNameIsValid: ${signUpForm.lastNameIsValid}");
      print("passwordIsEquals: ${signUpForm.passwordIsEquals}");
    }

    return signUpForm;
  }

  Timer waitConfirmation;

  stopWaitEmailConfirmation() {
    waitConfirmation.cancel();
  }

  waitEmailConfirmation({String email, String password}) async {
    if (waitConfirmation != null) {
      waitConfirmation.cancel();
    }
    //run each 10 seconds
    waitConfirmation =
        new Timer.periodic(Duration(seconds: 10), (Timer t) async {
      auth.UserCredential currentUser;
      try {
        currentUser = await auth.FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        if (currentUser.user.emailVerified) {
          //signOut before signIn to update user information
          await auth.FirebaseAuth.instance.signOut();
          await auth.FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          //cancel the loop
          t.cancel();
        }
      } catch (e) {
        //cancel the loop
        t.cancel();
      }
    });
  }

  createUserFirestore(FormStatus signUpForm, String uid) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).set({
      'company': null,
      'cpf': signUpForm.cpfValue,
      'email': signUpForm.email,
      'name': signUpForm.name,
      'lastName': signUpForm.lastName,
      'imageProfile': null,
      'phone': null,
      'fcmToken': null,
      'firstAccess': true
    });
    print("FIRESTORE: createUserFirestore");
  }

  resetPassword({String email}) async {
    try {
      await auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      return Exception(e);
    }
  }

  reauthentication({String email, String password}) async {
    try {
      var baseUser = auth.FirebaseAuth.instance.currentUser;
      await baseUser.reauthenticateWithCredential(
          auth.EmailAuthProvider.credential(email: email, password: password));
    } catch (e) {
      print("reauthentication error: " + e.toString());
      throw e;
    }
  }

  ///Reauthentication is required
  updatePassword({String newPassword}) async {
    try {
      var currentUser = auth.FirebaseAuth.instance.currentUser;

      await currentUser.updatePassword(newPassword);
    } catch (e) {
      print("updatePassword error: " + e.toString());
      throw e;
    }
  }

  ///Reauthentication is required
  updateUserEmail({String newEmail}) async {
    try {
      var currentUser = auth.FirebaseAuth.instance.currentUser;
      await currentUser.updateEmail(newEmail);
      await currentUser.sendEmailVerification();
      var newIdToken = await currentUser.getIdToken(true);
      print(newIdToken);
    } catch (e) {
      throw e;
    }
  }

  updateFirstAccess(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({"firstAccess": false});
    } catch (e) {
      print(e);
    }
  }
}
