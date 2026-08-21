import 'dart:ui';

import 'package:flame/components.dart';

class LightenedSpriteComponent extends SpriteComponent {
  LightenedSpriteComponent({required super.sprite, super.size, super.anchor})
    : super(paint: _lightenPaint);

  static final Paint _lightenPaint = Paint()
    ..colorFilter = const ColorFilter.mode(
      Color(0x40FFFFFF),
      BlendMode.srcATop,
    );
}
