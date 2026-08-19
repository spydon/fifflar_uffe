import 'dart:math';

import 'package:flame/components.dart';

/// Scales a HUD element down on narrow screens so that the fixed
/// design sizes keep fitting side by side.
mixin HudAutoScale on PositionComponent {
  static const double fullWidth = 520;

  static double factorFor(Vector2 gameSize) => min(1, gameSize.x / fullWidth);

  @override
  void onGameResize(Vector2 size) {
    scale = Vector2.all(factorFor(size));
    super.onGameResize(size);
  }
}
