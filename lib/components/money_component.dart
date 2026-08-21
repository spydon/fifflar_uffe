import 'dart:math';

import 'package:fifflar_uffe/components/floating_text_component.dart';
import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/game/play_world.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';

class MoneyComponent extends SpriteComponent
    with TapCallbacks, HasGameReference<FifflarUffeGame>, ParentIsA<PlayWorld> {
  MoneyComponent()
    : super(size: Vector2.all(72), anchor: Anchor.center, priority: 1);

  static final Random _random = Random();

  late final double _speed = 60 + _random.nextDouble() * 80;
  bool _collected = false;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache(AssetPaths.iconCoin));
    final lifetime = 8 + _random.nextDouble() * 4;
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.6, startDelay: lifetime),
        onComplete: removeFromParent,
      ),
    );
    _wander();
  }

  void _wander() {
    if (_collected || isRemoving) {
      return;
    }
    final rect = parent.playRect;
    final target = Vector2(
      rect.left + _random.nextDouble() * rect.width,
      rect.top + _random.nextDouble() * rect.height,
    );
    final duration = max(target.distanceTo(position) / _speed, 0.1);
    add(
      MoveToEffect(
        target,
        EffectController(duration: duration, curve: Curves.easeInOut),
        onComplete: _wander,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_collected) {
      return;
    }
    _collected = true;
    game.economy.earnClick();
    game.sound?.playCoin();
    parent.add(
      FloatingTextComponent(
        text: '+${formatSek(game.economy.clickValue)}',
        position: position - Vector2(0, size.y / 2),
      ),
    );
    for (final effect in children.whereType<Effect>().toList()) {
      effect.removeFromParent();
    }
    add(
      ScaleEffect.to(
        Vector2.all(1.4),
        EffectController(duration: 0.09),
        onComplete: removeFromParent,
      ),
    );
    add(OpacityEffect.fadeOut(EffectController(duration: 0.09)));
  }
}
