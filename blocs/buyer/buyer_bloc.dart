import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vimob/models/buyer/buyer.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/proposal/proposal.dart';

class BuyerBloc {
  Future<Stream<List<Buyer>>> fetchBuyers(
      {String uid, String companyId, int userExternalId}) async {
    var buyerList = BehaviorSubject<List<Buyer>>();

    var buyerRefByUid = FirebaseFirestore.instance
        .collection("buyers")
        .where("user", isEqualTo: uid)
        .where("company.id", isEqualTo: companyId);

    var buyerDocs = await buyerRefByUid.get();

    print("FIRESTORE: fetchBuyers");

    if (buyerDocs.docs.isEmpty) {
      FirebaseFirestore.instance
          .collection("buyers")
          .where("userExternalId", isEqualTo: userExternalId)
          .where("company.id", isEqualTo: companyId)
          .snapshots()
          .listen((docs) {
        buyerList.add(mountBuyer(docs));
      });
      print("FIRESTORE: fetchBuyers");

      print("Buyers from userExternalId");
    } else {
      buyerRefByUid.snapshots().listen((docs) {
        buyerList.add(mountBuyer(docs));
      });

      print("Buyers from uid (deprecated)");
    }

    return buyerList;
  }

  List<Buyer> mountBuyer(QuerySnapshot docs) {
    List<Buyer> list = List<Buyer>();
    docs.docs.forEach((doc) {
      var buyer = Buyer()
        ..id = doc.id
        ..address = (Address()
          ..city = doc.data()['address']['city']
          ..complement = doc.data()['address']['complement']
          ..neighborhood = doc.data()['address']['neighborhood']
          ..number = doc.data()['address']['number']
          ..state = doc.data()['address']['state']
          ..streetAddress = doc.data()['address']['streetAddress']
          ..zipCode = doc.data()['address']['zipCode'])
        ..company = (Reference()
          ..id = doc.data()['company']['id']
          ..name = doc.data()['company']['name'])
        ..cpf = doc.data()['cpf']
        ..email = doc.data()['email']
        ..externalId = doc.data()['externalId'].toString()
        ..isSynchronized = doc.data()['synchronized']
        ..typePerson = doc.data()['typePerson']
        ..name = doc.data()['name']
        ..note = doc.data()['note']
        ..phone = doc.data()['phone']
        ..user = doc.data()['user'] ?? null
        ..userExternalId = doc.data()['userExternalId']?.toInt() ?? null;

      list.add(buyer);
      list.sort((a, b) => a.name.compareTo(b.name));
    });
    return list;
  }

  deleteBuyer({Buyer buyer}) async {
    await FirebaseFirestore.instance
        .collection("buyers")
        .doc(buyer.id)
        .delete();
    print("FIRESTORE: deleteBuyer");
  }

  updateBuyer({Buyer buyer}) async {
    await FirebaseFirestore.instance.collection("buyers").doc(buyer.id).update({
      "address": {
        "city": buyer.address.city,
        "complement": buyer.address.complement,
        "neighborhood": buyer.address.neighborhood,
        "number": buyer.address.number,
        "state": buyer.address.state,
        "streetAddress": buyer.address.streetAddress,
        "zipCode": buyer.address.zipCode,
      },
      "company": {
        "id": buyer.company.id,
        "name": buyer.company.name,
      },
      "cpf": buyer.cpf,
      "email": buyer.email,
      "externalId": buyer.externalId,
      "synchronized": buyer.isSynchronized,
      "typePerson": buyer.typePerson,
      "name": buyer.name,
      "note": buyer.note,
      "phone": buyer.phone,
      "user": buyer.user,
      "userExternalId": buyer.userExternalId
    });

    print("FIRESTORE: updateBuyer ");
  }

  Future<String> createBuyer({Buyer buyer}) async {
    try {
      var docRef = await FirebaseFirestore.instance.collection("buyers").add({
        "address": {
          "city": buyer.address.city,
          "complement": buyer.address.complement,
          "neighborhood": buyer.address.neighborhood,
          "number": buyer.address.number,
          "state": buyer.address.state,
          "streetAddress": buyer.address.streetAddress,
          "zipCode": buyer.address.zipCode,
        },
        "company": {
          "id": buyer.company.id,
          "name": buyer.company.name,
        },
        "cpf": buyer.cpf,
        "email": buyer.email,
        "externalId": buyer.externalId,
        "synchronized": buyer.isSynchronized,
        "typePerson": buyer.typePerson,
        "name": buyer.name,
        "note": buyer.note,
        "phone": buyer.phone,
        "user": buyer.user,
        "userExternalId": buyer.userExternalId
      });

      print("FIRESTORE: createBuyer");

      return docRef.id;
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Future<Buyer> fetchBuyerById({String id}) async {
  //   var doc =
  //       await FirebaseFirestore.instance.collection("buyers").doc(id).get();
  //   print("FIRESTORE: fetchBuyerById");

  //   Buyer buyer;
  //   if (doc.exists) {
  //     buyer = Buyer()
  //       ..id = doc.id
  //       ..address = (Address()
  //         ..city = doc.data()['address']['city']
  //         ..complement = doc.data()['address']['complement']
  //         ..neighborhood = doc.data()['address']['neighborhood']
  //         ..number = doc.data()['address']['number']
  //         ..state = doc.data()['address']['state']
  //         ..streetAddress = doc.data()['address']['streetAddress']
  //         ..zipCode = doc.data()['address']['zipCode'])
  //       ..company = (Reference()
  //         ..id = doc.data()['company']['id']
  //         ..name = doc.data()['company']['name'])
  //       ..cpf = doc.data()['cpf']
  //       ..email = doc.data()['email']
  //       ..externalId = doc.data()['externalId'].toString()
  //       ..isSynchronized = doc.data()['synchronized']
  //       ..typePerson = doc.data()['typePerson']
  //       ..name = doc.data()['name']
  //       ..note = doc.data()['note']
  //       ..phone = doc.data()['phone']
  //       ..user = doc.data()['user']
  //       ..userExternalId = doc.data()['userExternalId'];
  //   }
  //   return buyer;
  // }
}
