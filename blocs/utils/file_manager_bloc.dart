import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileManagerBloc {
  Future<File> createFile(
      {@required String src, @required String fileName}) async {
    try {
      String dir = (await getApplicationDocumentsDirectory()).path;
      bool _fileExist = await File('$dir/$fileName').exists();

      if (_fileExist) {
        print("****from cache*****");
        return File('$dir/$fileName');
      } else {
        final url = src;
        var request = await HttpClient().getUrl(Uri.parse(url));
        var response = await request.close();
        var bytes = await consolidateHttpClientResponseBytes(response);
        File file = new File('$dir/$fileName');
        await file.writeAsBytes(bytes);
        print("****from internet*****");

        return file;
      }
    } catch (e) {
      rethrow;
    }
  }
}
