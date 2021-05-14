import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vimob/models/invite/invite.dart';
import 'package:vimob/models/user/user.dart';

class InviteBloc {
  ///Split code in hash/userPortal
  ///Example of [code]: "e1eef796db3d078982392ff8e24ff078;1035"
  Future<InviteHash> fetchHash({String code}) async {
    var inviteDocs = await FirebaseFirestore.instance
        .collection("invitations-code")
        .where('code', isEqualTo: code)
        .get();

    if (inviteDocs.docs.isNotEmpty) {
      print("FIRESTORE: fetchHash");

      return splitInviteHash(hash: inviteDocs.docs.first.data()['hash']);
    } else {
      throw ("CODE_NOT_EXIST");
    }
  }

  Future<CompanyJoin> fetchCompany({String id}) async {
    var companyDoc =
        await FirebaseFirestore.instance.collection("companies").doc(id).get();

    CompanyJoin company;
    if (companyDoc.exists) {
      print("FIRESTORE: fetchCompany");

      company = CompanyJoin()
        ..idCompany = id
        ..name = companyDoc.data()['name'];
    }

    return company;
  }

  Future<Invite> fecthInvite({InviteHash inviteHash}) async {
    var inviteDocs = await FirebaseFirestore.instance
        .collection("invitations")
        .doc(inviteHash.companyId)
        .collection("invites")
        .where('userId', isEqualTo: inviteHash.userPortal)
        .get();

    Invite invite;
    if (inviteDocs.docs.isNotEmpty) {
      print("FIRESTORE: fecthInvite");

      var doc = inviteDocs.docs.first;
      invite = Invite()
        ..docId = doc.id
        ..amount = doc.data()['amount'].toInt()
        ..salesCompany = doc.data()['salesCompany']
        ..used = doc.data()['used'].toInt()
        ..externalId = doc.data()['userId'].toInt()
        ..showPopUp = doc.data()['showPopUp'];
    }

    return invite;
  }

  ///Will update invite and add company information to user
  useInvite(
      {Invite invite,
      InviteHash inviteHash,
      User user,
      CompanyJoin company}) async {
    if (invite.amount > invite.used) {
      await _updateInvite(company: company, invite: invite, uid: user.uid);
      await _addCompany(
          uid: user.uid, company: company, inviteHash: inviteHash);
    } else {
      if (invite.salesCompany) {
        throw Exception("CODE_ALREADY_USED_SALES_COMPANY");
      } else {
        throw Exception("CODE_ALREADY_USED");
      }
    }
  }

  _addCompany({String uid, CompanyJoin company, InviteHash inviteHash}) {
    _addDefaultCompanyToUser(uid: uid, company: company);
    _addCompanyToUser(uid: uid, company: company, inviteHash: inviteHash);
  }

  _addDefaultCompanyToUser({String uid, CompanyJoin company}) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'company': company.idCompany,
        'companyName': company.name,
      });
      print("FIRESTORE: _addDefaultCompanyToUser");
    } catch (e) {
      print(e);
    }
  }

  _addCompanyToUser(
      {String uid, CompanyJoin company, InviteHash inviteHash}) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    var companies = Map<dynamic, Object>();

    if (userDoc.exists && userDoc.data()['companies'] != null) {
      print("FIRESTORE: _addCompanyToUser(fetch user)");

      (userDoc.data()['companies'] as Map<dynamic, dynamic>)
          .forEach((key, value) {
        companies[key] = {
          "externalId": value['externalId'],
          "name": value['name'],
          'id': value['id'],
          'status': value['status'],
        };
      });
    }

    companies[company.idCompany] = {
      'id': company.idCompany,
      'name': company.name,
      'externalId': inviteHash.userPortal,
      'status': true
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'companies': companies});

      print("FIRESTORE: _addCompanyToUser(updateData user)");
    } catch (e) {
      print(e);
    }
  }

  InviteHash splitInviteHash({String hash}) {
    InviteHash inviteHash = InviteHash();
    inviteHash.companyId = hash.split(";")[0].trim();
    inviteHash.userPortal = int.parse(hash.split(";")[1].trim());

    return inviteHash;
  }

  _updateInvite({Invite invite, CompanyJoin company, String uid}) async {
    invite.used++;

    var inviteDoc = await FirebaseFirestore.instance
        .collection("invitations")
        .doc(company.idCompany)
        .collection("invites")
        .doc(invite.docId)
        .get();

    if (inviteDoc.exists) {
      print("FIRESTORE: _updateInvite(fetch invitations)");

      var users = inviteDoc.data()['users'];

      if (users[uid] == null || !users[uid]) {
        users[uid] = "pending";

        await FirebaseFirestore.instance
            .collection("invitations")
            .doc(company.idCompany)
            .collection("invites")
            .doc(invite.docId)
            .update({'users': users, 'used': invite.used});
        print("FIRESTORE: _updateInvite(updateData invitations)");
      }
    }
  }
}
