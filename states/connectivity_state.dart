import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';

class ConnectivityState extends ChangeNotifier {
  factory ConnectivityState() => instance;
  static var instance = ConnectivityState._internal();
  ConnectivityState._internal();

  bool hasInternet = true;
  StreamSubscription<ConnectivityResult> internetListener;

  checkInternet() async {
    if (internetListener != null) {
      await internetListener.cancel();
    }
    internetListener = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      hasInternet = result != ConnectivityResult.none;
      notifyListeners();
    });
  }
}
