import 'package:flutter/material.dart';
import 'package:vimob/blocs/utils/global_settings_bloc.dart';
import 'package:vimob/models/utils/global_settings.dart';

class GlobalSettingsState with ChangeNotifier {
  factory GlobalSettingsState() => instance;
  GlobalSettingsState._internal();
  static var instance = GlobalSettingsState._internal();

  GlobalSettings globalSettings;

  fetchGlobalSettings() async {
    globalSettings = await GlobalSettingsBloc().fetchGlobalSettings();
    notifyListeners();
  }
}
