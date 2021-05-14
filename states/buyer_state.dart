import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:vimob/blocs/buyer/buyer_bloc.dart';
import 'package:vimob/models/buyer/buyer.dart';
import 'package:vimob/models/user/user.dart';

class BuyerState with ChangeNotifier {
  factory BuyerState() => instance;
  BuyerState._internal();
  static var instance = BuyerState._internal();

  bool _isEditing = false;

  bool get isEditing => _isEditing;

  set isEditing(bool isEditing) {
    _isEditing = isEditing;
    notifyListeners();
  }

  var buyersList = BehaviorSubject<List<Buyer>>();

  StreamSubscription _listener;

  fetchBuyers({String uid, String companyId, int userExternalId}) async {
    if (_listener != null) {
      buyersList.add([]);
      await _listener.cancel();
    }
    var listener = await BuyerBloc().fetchBuyers(
        uid: uid, companyId: companyId, userExternalId: userExternalId);

    _listener = listener.listen((streamBuyerList) {
      buyersList.add(streamBuyerList);
    });
  }

  updateBuyer(Buyer buyer) async {
    try {
      await BuyerBloc().updateBuyer(buyer: buyer);
      isEditing = false;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<Buyer> createBuyer({Buyer buyer, User user}) async {
    try {
      var buyerId = await BuyerBloc().createBuyer(buyer: buyer);
      notifyListeners();

      if (buyersList.value == null) {
        fetchBuyers(companyId: user.company, uid: user.uid);
      }

      return buyersList.value.firstWhere((buyer) => buyer.id == buyerId);
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Future dispose() async {
    await _listener.cancel();
    super.dispose();
  }
}
