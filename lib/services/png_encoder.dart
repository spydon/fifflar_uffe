import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';

class PngEncoder {
  PngEncoder._();

  static const List<int> _signature = [137, 80, 78, 71, 13, 10, 26, 10];

  static Future<Uint8List> encode(ui.Image image) async {
    final data = await image.toByteData();
    final width = image.width;
    final height = image.height;
    final pixels = data!.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final stride = width * 4;
    final filtered = Uint8List(height * (stride + 1));
    for (var row = 0; row < height; row++) {
      final source = row * stride;
      final target = row * (stride + 1);
      filtered[target] = 0;
      filtered.setRange(
        target + 1,
        target + 1 + stride,
        pixels,
        source,
      );
    }
    final header = ByteData(13)
      ..setUint32(0, width)
      ..setUint32(4, height)
      ..setUint8(8, 8)
      ..setUint8(9, 6)
      ..setUint8(10, 0)
      ..setUint8(11, 0)
      ..setUint8(12, 0);
    final builder = BytesBuilder(copy: false)
      ..add(_signature)
      ..add(_chunk('IHDR', header.buffer.asUint8List()))
      ..add(
        _chunk(
          'IDAT',
          Uint8List.fromList(const ZLibEncoder().encode(filtered)),
        ),
      )
      ..add(_chunk('IEND', Uint8List(0)));
    return builder.takeBytes();
  }

  static Uint8List _chunk(String type, Uint8List body) {
    final typeBytes = type.codeUnits;
    final chunk = BytesBuilder(copy: false)
      ..add((ByteData(4)..setUint32(0, body.length)).buffer.asUint8List())
      ..add(typeBytes)
      ..add(body);
    final crc = getCrc32([...typeBytes, ...body]);
    chunk.add((ByteData(4)..setUint32(0, crc)).buffer.asUint8List());
    return chunk.takeBytes();
  }
}
