import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class FloatingTextComponent extends TextComponent {
  FloatingTextComponent({required super.text, required super.position})
    : super(
        anchor: Anchor.center,
        priority: 2,
        textRenderer: TextStyles.floating,
      );

  static const double _lifetime = 0.8;
  static const double _fadeStart = 0.3;

  double _age = 0;

  @override
  void onMount() {
    super.onMount();
    add(
      MoveByEffect(
        Vector2(0, -60),
        EffectController(duration: _lifetime, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _lifetime) {
      removeFromParent();
      return;
    }
    if (_age > _fadeStart) {
      final progress = (_age - _fadeStart) / (_lifetime - _fadeStart);
      textRenderer = TextPaint(
        style: TextStyles.floatingStyle.copyWith(
          color: TextStyles.floatingGreen.withValues(alpha: 1 - progress),
        ),
      );
    }
  }
}
