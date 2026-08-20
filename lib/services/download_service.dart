import 'dart:typed_data';

import 'package:fifflar_uffe/services/download_service_io.dart'
    if (dart.library.js_interop) 'package:fifflar_uffe/services/download_service_web.dart'
    as platform;

class DownloadService {
  DownloadService._();

  static Future<void> downloadPng(Uint8List bytes, String fileName) {
    return platform.downloadPng(bytes, fileName);
  }
}
