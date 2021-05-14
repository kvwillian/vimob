import 'dart:async';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:vimob/blocs/payment/payment_bloc.dart';
import 'package:vimob/models/payment/payment.dart';

class PaymentState with ChangeNotifier {
  factory PaymentState() => instance;
  PaymentState._internal();
  static var instance = PaymentState._internal();

  var paymentPlans = BehaviorSubject<List<PaymentPlan>>();
  var modifiedPaymentSeries = List<PaymentSeries>();
  var intialModifiedPaymentSeries = List<PaymentSeries>();

  List<PaymentSeries> availableSeriesToDilute = [];
  List<PaymentSeries> selectedSeriesToDilute = [];

  Jiffy upfrontFirstDate;
  Jiffy upfrontLastDate;

  PaymentSeries selectedSeries;
  PaymentSeries modifiedSelectedSeries;

  StreamSubscription _listener;

  fetchPaymentsList() async {
    if (_listener != null) {
      paymentPlans.add([]);
      await _listener.cancel();
    }

    _listener = Stream<List<PaymentPlan>>.fromFuture(
      PaymentBloc().fetchPaymentPlans(),
    ).listen((paymentsStream) async {
      await PaymentBloc().applyPostDeliveryDistribute();
      paymentPlans.add(paymentsStream);
      notifyListeners();
    });
  }

  void saveSeries() {
    notifyListeners();
  }

  void removeSeries() {
    notifyListeners();
  }

  @override
  Future dispose() async {
    await _listener.cancel();
    super.dispose();
  }
}
