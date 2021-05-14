import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vimob/models/development/development.dart';
import 'package:vimob/models/proposal/proposal.dart';
import 'package:vimob/models/user/user.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/buyer_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/ui/proposal/proposal_detail_page.dart';

class NotificationBloc {
  factory NotificationBloc() => instance;

  // @visibleForTesting
  static var instance = NotificationBloc._internal();
  NotificationBloc._internal();

  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  FirebaseMessaging _firebaseMessaging;
  AndroidInitializationSettings _androidInitializationSettings;
  IOSInitializationSettings _iOSInitializationSettings;
  InitializationSettings _initializationSettings;

  configFirebaseCloudMessaging({User user, BuildContext context}) async {
    _firebaseMessaging = FirebaseMessaging();
    await initializeLocalNotificationConfig(context);

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage => $message");
        print("proposalId =>  ${message['proposalId']}");
        await _pushNotificationMessage(
            title: message['notification']['title'],
            body: message['notification']['body'],
            payload: Platform.isIOS
                ? message['proposalId']
                : message['data']['proposalId']);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch => $message");

        redirectToProposalDetailPage(
            Platform.isIOS
                ? message['proposalId']
                : message['data']['proposalId'],
            context);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume => $message");

        redirectToProposalDetailPage(
            Platform.isIOS
                ? message['proposalId']
                : message['data']['proposalId'],
            context);
      },
    );

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      if (user.fcmToken != newToken) {
        onTokenUpdate(uid: user.uid, token: newToken);
      }
    });
  }

  Future<void> redirectToProposalDetailPage(
      String payload, BuildContext context) async {
    try {
      if (ProposalState().currentProposals == null) {
        await ProposalState().fetchPropsalsList(
            companyId: AuthenticationState().user.company,
            uid: AuthenticationState().user.uid);
        await BuyerState().fetchBuyers(
            companyId: AuthenticationState().user.company,
            uid: AuthenticationState().user.uid);
      }

      Proposal proposal = ProposalState()
          .currentProposals
          .value
          .singleWhere((p) => p.idProposalMega.toString() == payload);

      var developments = DevelopmentState().developments.value;

      Development development = developments.singleWhere(
          (development) => development.id == proposal.development.id);

      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProposalDetailPage(
                    proposal: proposal,
                    development: development,
                    initialIndex: 1,
                  )));
    } catch (e) {
      print(e);
    }
  }

  initializeLocalNotificationConfig(BuildContext context) async {
    _androidInitializationSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    _iOSInitializationSettings = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    _initializationSettings = InitializationSettings(
        android: _androidInitializationSettings,
        iOS: _iOSInitializationSettings);

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await _flutterLocalNotificationsPlugin.initialize(
      _initializationSettings,
      onSelectNotification: (payload) async {
        if (payload != null) {
          redirectToProposalDetailPage(payload, context);
        }
      },
    );
  }

  Future<void> _pushNotificationMessage(
      {String title, String body, String payload}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channelIdVimob',
      'Vimob',
      'description',
      playSound: true,
    );
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
        0, title, body + payload, platformChannelSpecifics,
        payload: payload);
  }

  onTokenUpdate({String uid, String token}) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({'fcmToken': token});
  }

  Future<String> getTokenFcm() async {
    return await _firebaseMessaging.getToken();
  }
}
