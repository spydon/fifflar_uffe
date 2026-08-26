import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

class TextStyles {
  TextStyles._();

  static TextPaint enlarged(TextPaint base, double factor) => TextPaint(
    style: base.style.copyWith(fontSize: base.style.fontSize! * factor),
  );

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

  static final subCounter = TextPaint(
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: lightBrown,
    ),
  );

  static final paragraph = TextPaint(
    style: const TextStyle(fontSize: 19, color: brown),
  );

  static final note = TextPaint(
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: brown,
      height: 1.3,
    ),
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

  static final eventTitle = TextPaint(
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: brown,
    ),
  );

  static final eventBody = TextPaint(
    style: const TextStyle(fontSize: 15, color: brown),
  );

  static final eventLink = TextPaint(
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1B6CA8),
      decoration: TextDecoration.underline,
    ),
  );

  static final statLabel = TextPaint(
    style: const TextStyle(fontSize: 17, color: lightBrown),
  );

  static final statValue = TextPaint(
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: brown,
    ),
  );

  static final statValueMuted = TextPaint(
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Color(0x805B4632),
    ),
  );

  static final statValueHighlight = TextPaint(
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: floatingGreen,
    ),
  );

  static final placeholder = TextPaint(
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0x805B4632),
    ),
  );

  static final treePrice = TextPaint(
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: brown,
    ),
  );

  static final treePriceDisabled = TextPaint(
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0x805B4632),
    ),
  );

  static final hint = TextPaint(
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFFFFF6E3),
      shadows: [
        Shadow(color: Color(0xB3000000), offset: Offset(0, 2), blurRadius: 3),
      ],
    ),
  );

  static const Color floatingGreen = Color(0xFF2E9940);

  static const floatingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: floatingGreen,
  );

  static final floating = TextPaint(style: floatingStyle);
}
