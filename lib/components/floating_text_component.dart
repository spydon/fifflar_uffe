import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

class FloatingTextComponent extends TextComponent {
  FloatingTextComponent({
    required super.text,
    required super.position,
    TextStyle? style,
    this.lifetime = 0.8,
    super.priority = 2,
  }) : _style = style ?? TextStyles.floatingStyle,
       super(
         anchor: Anchor.center,
         textRenderer: TextPaint(style: style ?? TextStyles.floatingStyle),
       );

  static const double _fadeStartFraction = 0.375;

  final TextStyle _style;
  final double lifetime;

  double _age = 0;

  @override
  void onMount() {
    super.onMount();
    add(
      MoveByEffect(
        Vector2(0, -60),
        EffectController(duration: lifetime, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= lifetime) {
      removeFromParent();
      return;
    }
    final fadeStart = lifetime * _fadeStartFraction;
    if (_age > fadeStart) {
      final progress = (_age - fadeStart) / (lifetime - fadeStart);
      textRenderer = TextPaint(
        style: _style.copyWith(
          color: _style.color!.withValues(alpha: 1 - progress),
        ),
      );
    }
  }
}
