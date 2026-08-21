import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

mixin HoverLighten on Component, HoverCallbacks {
  static const Color _highlight = Color(0xFFFFFFFF);
  static const double _opacity = 0.25;
  static const double _duration = 0.12;

  Iterable<Component> get hoverTargets {
    final self = this;
    if (self is AdvancedButtonComponent) {
      final skin = (self as AdvancedButtonComponent).defaultSkin;
      return [if (skin != null && skin is HasPaint) skin];
    }
    return [
      if (self is HasPaint) self,
      ...descendants().whereType<HasPaint>().cast<Component>(),
    ];
  }

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
    for (final target in hoverTargets.toList()) {
      for (final effect in target.children.whereType<ColorEffect>().toList()) {
        effect.removeFromParent();
      }
      target.add(
        ColorEffect(
          _highlight,
          EffectController(duration: _duration),
          opacityFrom: from,
          opacityTo: to,
        ),
      );
    }
  }
}
