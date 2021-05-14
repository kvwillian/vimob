import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vimob/models/company/company.dart';
import 'package:vimob/models/user/user.dart';

class UserBloc {
  UserBloc();

  Future<User> fetchUserInformationByUid({String uid}) async {
    var userDoc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    var user = User();
    if (userDoc.exists) {
      print("FIRESTORE: users");

      user = User()
        ..uid = userDoc.id
        ..cpf = userDoc.data()['cpf'] ?? null
        ..imageProfile = userDoc.data()['imageProfile'] ?? null
        ..phone = userDoc.data()['phone'] ?? null
        ..email = userDoc.data()['email'] ?? null
        ..name = userDoc.data()['name'] ?? null
        ..lastName = userDoc.data()['lastName'] ?? null
        ..company = userDoc.data()['company'] ?? null
        ..companies = mountCompanyList(userDoc) ?? null
        ..companyName = userDoc.data()['companyName'] ?? null
        ..fcmToken = userDoc.data()['fcmToken'] ?? null
        ..firstAccess = userDoc.data()['firstAccess'] ?? null
        ..language = userDoc.data()['language'] ?? null;
    }
    return user;
  }

  Map<String, Company> mountCompanyList(DocumentSnapshot userDoc) {
    var companyList = Map<String, Company>();

    if (userDoc.data()['companies'] != null) {
      (userDoc.data()['companies'] as Map<dynamic, dynamic>)
          .forEach((key, value) {
        companyList[key] = Company()
          ..externalId = value["externalId"].toInt()
          ..id = value["id"]
          ..name = value['name']
          ..status = value['status']
          ..permissionId = value['permissionId'];
      });
    }

    return companyList;
  }

  Future<User> fetchUserInformationByCpf({String cpf}) async {
    var docs = await FirebaseFirestore.instance
        .collection("users")
        .where("cpf", isEqualTo: cpf)
        .get();
    var user = User();
    if (docs.docs.isNotEmpty) {
      print("FIRESTORE: users");

      var userDoc = docs.docs.first;
      user = User()
        ..uid = userDoc.id
        ..cpf = userDoc.data()['cpf'] ?? null
        ..imageProfile = userDoc.data()['imageProfile'] ?? null
        ..phone = userDoc.data()['phone'] ?? null
        ..email = userDoc.data()['email'] ?? null
        ..name = userDoc.data()['name'] ?? null
        ..lastName = userDoc.data()['lastName'] ?? null
        ..company = userDoc.data()['company'] ?? null
        ..companyName = userDoc.data()['companyName'] ?? null
        ..imageProfileName = userDoc.data()['imageProfileName'] ?? null
        ..fcmToken = userDoc.data()['fcmToken'] ?? null
        ..language = userDoc.data()['language'] ?? null
        ..companies = mountCompanyList(userDoc) ?? null
        ..language = userDoc.data()['language'] ?? null;
    }
    return user;
  }

  updateSelectedCompany(User user) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({'company': user.company, 'companyName': user.companyName});
    print("FIRESTORE: updateSelectedCompany");
  }

  storage.UploadTask uploadProfileImage({String uid, File image}) {
    storage.Reference ref = storage.FirebaseStorage.instance
        .ref()
        .child('usersImages/$uid/${basename(image.path)}');

    storage.UploadTask uploadTask = ref.putFile(image);

    return uploadTask;
  }

  updateProfileImage({String uid, String imageUrl, File file}) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).update(
        {'imageProfile': imageUrl, 'imageProfileName': basename(file.path)});
    print("FIRESTORE: updateProfileImage");
  }

  updateUserInformation({User user}) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      'name': user.name,
      'lastName': user.lastName,
      'phone': user.phone,
      'email': user.email,
    });
    print("FIRESTORE: updateUserInformation");
  }

  upadateUserLanguage(User user, Locale locale) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({'language': locale.languageCode});
    print("FIRESTORE: updateUserLanguage");
  }

  updateUserFcmToken(User user, String token) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({'fcmToken': token});
    print("FIRESTORE: updateUserFcmToken");
  }

  Future<String> getOptmizedProfileImageSize(
      {User user, double deviceWidth}) async {
    String fullName = user.imageProfileName;
    String resizedImage;
    // StorageMetadata metaData;
    if (fullName != null) {
      if (deviceWidth <= 320) {
        var ref = storage.FirebaseStorage.instance.ref().child(
                'usersImages/${user.uid}/${user.imageProfileName.replaceAll(".", "_320x480.")}') ??
            null;

        resizedImage = await ref.getDownloadURL() ?? null;

        // metaData = await ref.getMetadata() ?? null;
      } else {
        var ref = storage.FirebaseStorage.instance.ref().child(
                'usersImages/${user.uid}/${fullName.replaceAll(".", "_768x1280.")}') ??
            null;

        resizedImage = await ref.getDownloadURL() ?? null;

        // metaData = await ref.getMetadata() ?? null;
      }
    }
    return resizedImage;
  }

  BehaviorSubject<UserPermissions> fetchUserPermissions(String permissionId) {
    BehaviorSubject<UserPermissions> userPermission =
        BehaviorSubject<UserPermissions>()..add(UserPermissions());
    try {
      FirebaseFirestore.instance
          .collection("user-permissions")
          .doc(permissionId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          print("FIRESTORE: fetchUserPermissions");

          userPermission.add(UserPermissions()
            ..id = snapshot.id
            ..reserveEnabled = snapshot.data()['reserveEnabled']);
        }
      });

      return userPermission;
    } catch (e) {
      print(e);
      return userPermission;
    }
  }
}
