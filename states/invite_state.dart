import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:vimob/blocs/company/invite_bloc.dart';
import 'package:vimob/blocs/user/user_bloc.dart';
import 'package:vimob/models/invite/invite.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/authentication_state.dart';

class InviteState with ChangeNotifier {
  InviteState();

  Invite invite = Invite();
  CompanyJoin companyJoin = CompanyJoin();
  InviteHash inviteHash;

  String codeValue = "";
  String errorMessage;
  bool inProgress = false;

  useInvite({User user, String code, String qrcode}) async {
    inProgress = true;
    notifyListeners();
    try {
      if (qrcode != null) {
        inviteHash = InviteBloc().splitInviteHash(hash: qrcode);
      } else {
        inviteHash = await InviteBloc().fetchHash(code: code);
      }

      if (inviteHash != null) {
        companyJoin = await InviteBloc().fetchCompany(id: inviteHash.companyId);

        invite = await InviteBloc().fecthInvite(inviteHash: inviteHash);

        if (invite != null) {
          await InviteBloc().useInvite(
              company: companyJoin,
              invite: invite,
              inviteHash: inviteHash,
              user: user);

          var userAuth = auth.FirebaseAuth.instance.currentUser;
          var idToken = await userAuth.getIdToken(true);
          await userAuth.reload();

          AuthenticationState().user =
              await UserBloc().fetchUserInformationByUid(uid: user.uid);

          print("token: $idToken");
          errorMessage = null;
          await userAuth.getIdToken(true);
          await userAuth.reload();
          notifyListeners();
        } else {
          throw "CODE_NOT_EXIST";
        }
      } else {
        throw "CODE_NOT_EXIST";
      }
      inProgress = false;
      notifyListeners();
    } catch (e) {
      inProgress = false;
      notifyListeners();
      print(e);
      throw e;
    }
  }

  handleInviteCode({String code}) {
    codeValue = code;
    notifyListeners();
  }
}
