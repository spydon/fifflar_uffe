import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

mixin HoverLighten on AdvancedButtonComponent {
  static const Color _highlight = Color(0xFFFFFFFF);
  static const double _opacity = 0.25;
  static const double _duration = 0.12;

  @override
  void onHoverEnter() {
    super.onHoverEnter();
    _tint(0, _opacity);
  }

  @override
  void onHoverExit() {
    super.onHoverExit();
    _tint(_opacity, 0);
  }

  @override
  void onHoverCancel() {
    super.onHoverCancel();
    _tint(_opacity, 0);
  }

  void _tint(double from, double to) {
    final skin = defaultSkin;
    if (skin == null || skin is! HasPaint) {
      return;
    }
    for (final effect in skin.children.whereType<ColorEffect>().toList()) {
      effect.removeFromParent();
    }
    skin.add(
      ColorEffect(
        _highlight,
        EffectController(duration: _duration),
        opacityFrom: from,
        opacityTo: to,
      ),
    );
  }
}
