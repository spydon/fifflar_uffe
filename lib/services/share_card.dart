import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fifflar_uffe/services/strings.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flutter/painting.dart';

class ShareCard {
  ShareCard({
    required this.background,
    required this.head,
    required this.strings,
    required this.totalEarned,
  });

  static const double width = 1200;
  static const double height = 630;

  static const Color _cream = Color(0xFFFFF6E3);
  static const Color _gold = Color(0xFFFFC83D);
  static const List<Shadow> _shadows = [
    Shadow(color: Color(0xE6000000), offset: Offset(0, 3), blurRadius: 10),
    Shadow(color: Color(0x99000000), blurRadius: 28),
  ];

  static const Rect _headSourceRect = Rect.fromLTWH(200, 0, 205, 200);
  static const double _headWidth = 470;
  static const double _headCenterX = 270;
  static const double _headOverhang = 40;
  static const double _headTilt = -0.14;
  static const double _textLeft = 560;
  static const double _textRight = 1140;
  static const String _nonBreakingHyphen = '\u2011';

  final ui.Image background;
  final ui.Image head;
  final Strings strings;
  final double totalEarned;

  Future<Uint8List> toPng() async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      const Rect.fromLTWH(0, 0, width, height),
    );
    paint(canvas);
    final image = await recorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  void paint(ui.Canvas canvas) {
    _paintBackground(canvas);
    _paintHead(canvas);
    _paintText(canvas);
  }

  void _paintBackground(ui.Canvas canvas) {
    const target = Rect.fromLTWH(0, 0, width, height);
    final scale = max(width / background.width, height / background.height);
    final cropWidth = width / scale;
    final cropHeight = height / scale;
    final source = Rect.fromLTWH(
      (background.width - cropWidth) / 2,
      (background.height - cropHeight) * 0.35,
      cropWidth,
      cropHeight,
    );
    canvas.drawImageRect(
      background,
      source,
      target,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.drawRect(
      target,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(0, height),
          const [Color(0x73000000), Color(0xB3000000)],
        ),
    );
  }

  void _paintHead(ui.Canvas canvas) {
    final headHeight =
        _headWidth * _headSourceRect.height / _headSourceRect.width;
    canvas
      ..save()
      ..translate(_headCenterX, height + _headOverhang)
      ..rotate(_headTilt)
      ..drawImageRect(
        head,
        _headSourceRect,
        Rect.fromLTWH(-_headWidth / 2, -headHeight, _headWidth, headHeight),
        Paint()..filterQuality = FilterQuality.high,
      )
      ..restore();
  }

  void _paintText(ui.Canvas canvas) {
    const maxWidth = _textRight - _textLeft;
    final lines = [
      _Line(
        strings.shareHeadline.replaceAll('-', _nonBreakingHyphen),
        const TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.w900,
          color: _cream,
          height: 1.08,
          shadows: _shadows,
        ),
        gapAfter: 22,
      ),
      _Line(
        strings.shareTagline,
        const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: _cream,
          height: 1.2,
          shadows: _shadows,
        ),
        gapAfter: 40,
      ),
      _Line(
        '${strings.finalScore}: ${formatSek(totalEarned)}',
        const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: _gold,
          shadows: _shadows,
        ),
        gapAfter: 0,
      ),
    ];
    final painters = [
      for (final line in lines)
        TextPainter(
          text: TextSpan(text: line.text, style: line.style),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: maxWidth),
    ];
    var totalHeight = 0.0;
    for (var i = 0; i < lines.length; i++) {
      totalHeight += painters[i].height + lines[i].gapAfter;
    }
    var y = (height - totalHeight) / 2;
    for (var i = 0; i < lines.length; i++) {
      painters[i].paint(canvas, Offset(_textLeft, y));
      y += painters[i].height + lines[i].gapAfter;
    }
    final url = TextPainter(
      text: const TextSpan(
        text: 'fifflar-uffe.se',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: _gold,
          shadows: _shadows,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    url.paint(canvas, Offset(_textRight - url.width, height - url.height - 28));
  }
}

class _Line {
  const _Line(this.text, this.style, {required this.gapAfter});

  final String text;
  final TextStyle style;
  final double gapAfter;
}
