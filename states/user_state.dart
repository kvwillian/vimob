// import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:vimob/blocs/user/user_bloc.dart';
// import 'package:vimob/models/user/user.dart';
// import 'package:vimob/states/authentication_state.dart';
// import 'package:vimob/states/development_state.dart';

// class UserState with ChangeNotifier {
//   factory UserState() => instance;
//   UserState._internal();
//   static var instance = UserState._internal();

//   // var user = User();

//   // var isLogged = BehaviorSubject<bool>();

//   // final auth.FirebaseAuth auth = auth.FirebaseAuth.instance;
//   // checkLogin() {
//   //   auth.onAuthStateChanged.listen((firebaseUser) async {
//   //     String uid;
//   //     if (firebaseUser == null || !firebaseUser.emailVerified) {
//   //       isLogged.add(false);
//   //     } else {
//   //       uid = firebaseUser.uid;
//   //       isLogged.add(true);
//   //       fetchUser(uid: uid);
//   //     }
//   //   });
//   // }

//   // signOut() {
//   //   AuthenticationState().cleanForm();
//   //   auth.FirebaseAuth.instance.signOut();
//   //   user = User();
//   //   DevelopmentState().cleanStream();
//   //   notifyListeners();
//   // }

//   // signIn({String cpf, String password}) async {
//   //   try {
//   //     User user = await UserBloc().fetchUserInformationByCpf(cpf: cpf);

//   //     await auth.FirebaseAuth.instance
//   //         .signInWithEmailAndPassword(email: user.email, password: password);

//   //     isLogged.add(true);
//   //   } catch (e) {
//   //     isLogged.add(false);
//   //     rethrow;
//   //   }
//   // }

//   // fetchUser({String uid}) async {
//   //   user = await UserBloc().fetchUserInformationByUid(uid: uid);
//   //   notifyListeners();
//   // }
// }
