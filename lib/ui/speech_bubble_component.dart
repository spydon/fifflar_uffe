import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class SpeechBubbleComponent extends PositionComponent
    with HasGameReference<FifflarUffeGame>, HasVisibility {
  SpeechBubbleComponent({
    this.onTalkingChanged,
    super.position,
    super.anchor,
    super.priority,
  }) : super(size: Vector2(250, 164));

  static const double _displayDuration = 3;

  final void Function({required bool talking})? onTalkingChanged;

  late final TextBoxComponent _text;
  TimerComponent? _hideTimer;

  @override
  Future<void> onLoad() async {
    isVisible = false;
    addAll([
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.speechBubble)),
        size: size,
      ),
      _text = TextBoxComponent(
        textRenderer: TextStyles.bubble,
        boxConfig: const TextBoxConfig(maxWidth: 190),
        align: Anchor.center,
        anchor: Anchor.center,
        position: Vector2(size.x / 2 + 8, size.y / 2 - 16),
      ),
    ]);
  }

  void say(String message) {
    _hideTimer?.removeFromParent();
    for (final effect in children.whereType<ScaleEffect>().toList()) {
      effect.removeFromParent();
    }
    _text.text = message;
    isVisible = true;
    onTalkingChanged?.call(talking: true);
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.3, curve: Curves.easeOutBack),
      ),
    );
    _hideTimer = TimerComponent(
      period: _displayDuration,
      removeOnFinish: true,
      onTick: _hide,
    );
    add(_hideTimer!);
  }

  void _hide() {
    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.25, curve: Curves.easeIn),
        onComplete: () {
          isVisible = false;
          onTalkingChanged?.call(talking: false);
        },
      ),
    );
  }
}
