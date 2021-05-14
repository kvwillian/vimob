import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';
import 'package:vimob/models/utils/global_settings.dart';

class GlobalSettingsBloc {
  Future<GlobalSettings> fetchGlobalSettings() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection("global-settings")
          .doc("global")
          .get();
      print("FIRESTORE: fetchGlobalSettings");

      return GlobalSettings()
        ..minimumVersion = doc.data()["minimumVersion"] ?? 0
        ..packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      print(e);
      return null;
    }
  }

  bool versionValidation(int currentVersion, int minimumVersion) {
    return currentVersion >= minimumVersion;
  }
}
