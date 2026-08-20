import 'dart:typed_data';

import 'package:gal/gal.dart';

Future<void> downloadPng(Uint8List bytes, String fileName) async {
  if (!await Gal.hasAccess()) {
    final granted = await Gal.requestAccess();
    if (!granted) {
      return;
    }
  }
  await Gal.putImageBytes(bytes, name: fileName);
}
