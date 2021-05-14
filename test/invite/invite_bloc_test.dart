import 'package:flutter_test/flutter_test.dart';
import 'package:vimob/blocs/company/invite_bloc.dart';
import 'package:vimob/models/invite/invite.dart';

void main() {
  group("Invite Bloc", () {
    test("Split hash", () {
      InviteHash inviteHash = InviteBloc()
          .splitInviteHash(hash: "e1eef796db3d078982392ff8e24ff078;1035");

      expect(inviteHash.companyId, "e1eef796db3d078982392ff8e24ff078");
      expect(inviteHash.userPortal, 1035);
    });
  });
}
