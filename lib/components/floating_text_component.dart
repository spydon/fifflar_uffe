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

  @override
  void onMount() {
    super.onMount();
    paint.color = TextStyles.floatingGreen;
    addAll([
      MoveByEffect(
        Vector2(0, -60),
        EffectController(duration: 0.8, curve: Curves.easeOut),
      ),
      OpacityEffect.fadeOut(
        EffectController(duration: 0.5, startDelay: 0.3),
        onComplete: removeFromParent,
      ),
    ]);
  }
}
