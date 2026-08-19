import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

class TextStyles {
  TextStyles._();

  static const Color brown = Color(0xFF5B4632);
  static const Color lightBrown = Color(0xFF8A7156);

  static final title = TextPaint(
    style: const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: Color(0xFFFFF6E3),
      shadows: [Shadow(color: Color(0x80000000), offset: Offset(0, 2))],
    ),
  );

  static final button = TextPaint(
    style: const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Color(0xFFFFF6E3),
      shadows: [Shadow(color: Color(0x66000000), offset: Offset(0, 2))],
    ),
  );

  static final body = TextPaint(
    style: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: brown,
    ),
  );

  static final info = TextPaint(
    style: const TextStyle(fontSize: 17, color: lightBrown),
  );

  static final counter = TextPaint(
    style: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: brown,
    ),
  );

  static final paragraph = TextPaint(
    style: const TextStyle(fontSize: 19, color: brown),
  );

  static final bubble = TextPaint(
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: brown,
    ),
  );

  static final tileCount = TextPaint(
    style: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFFFFF6E3),
      shadows: [
        Shadow(color: Color(0xB3000000), offset: Offset(0, 1), blurRadius: 2),
      ],
    ),
  );

  static final priceTag = TextPaint(
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFFFFF6E3),
      shadows: [Shadow(color: Color(0x99000000), offset: Offset(0, 1))],
    ),
  );

  static final priceTagDisabled = TextPaint(
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0x80FFF6E3),
      shadows: [Shadow(color: Color(0x66000000), offset: Offset(0, 1))],
    ),
  );

  static final floating = TextPaint(
    style: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2E9940),
      shadows: [Shadow(color: Color(0x99FFFFFF), blurRadius: 4)],
    ),
  );
}
