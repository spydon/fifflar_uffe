import 'dart:ui' as ui;

import 'package:fifflar_uffe/services/png_encoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('encodes exactly the image size with intact pixels', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawRect(
        const ui.Rect.fromLTWH(0, 0, 3, 2),
        ui.Paint()..color = const ui.Color(0xFF112233),
      );
      canvas.drawRect(
        const ui.Rect.fromLTWH(2, 1, 1, 1),
        ui.Paint()..color = const ui.Color(0xFFFF0000),
      );
      final image = await recorder.endRecording().toImage(3, 2);
      final png = await PngEncoder.encode(image);
      expect(png.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
      final codec = await ui.instantiateImageCodec(png);
      final decoded = (await codec.getNextFrame()).image;
      expect(decoded.width, 3);
      expect(decoded.height, 2);
      final pixels = (await decoded.toByteData())!.buffer.asUint8List();
      expect(pixels.sublist(0, 4), [0x11, 0x22, 0x33, 0xFF]);
      const last = (1 * 3 + 2) * 4;
      expect(pixels.sublist(last, last + 4), [0xFF, 0x00, 0x00, 0xFF]);
    });
  });
}
