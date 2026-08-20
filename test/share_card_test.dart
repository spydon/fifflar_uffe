import 'dart:io';
import 'dart:ui' as ui;

import 'package:fifflar_uffe/services/share_card.dart';
import 'package:fifflar_uffe/services/strings.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ui.Image> _loadImage(String path) async {
  final bytes = await File(path).readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}

void main() {
  testWidgets('share card renders a social media sized PNG', (tester) async {
    await tester.runAsync(() async {
      final card = ShareCard(
        background: await _loadImage('assets/images/riksdag_bg.jpg'),
        head: await _loadImage('assets/images/uffe_head.png'),
        strings: const SvStrings(),
        totalEarned: 12345678,
      );
      final png = await card.toPng();
      expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
      final codec = await ui.instantiateImageCodec(png);
      final image = (await codec.getNextFrame()).image;
      expect(image.width, ShareCard.width.toInt());
      expect(image.height, ShareCard.height.toInt());
    });
  });
}
