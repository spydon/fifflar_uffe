import 'dart:math';

import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/scrim_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

abstract class ModalPage extends PositionComponent
    with HasGameReference<FifflarUffeGame> {
  ModalPage({required this.designSize, this.dismissOnScrimTap = true});

  static const double _scrimOpacity = 0.6;
  static const double _openDuration = 0.3;
  static const double _closeDuration = 0.2;

  final Vector2 designSize;
  final bool dismissOnScrimTap;

  late final ScrimComponent scrim;
  late final PositionComponent panel;
  late Vector2 _fitScale;
  bool _closing = false;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    scrim = ScrimComponent(onTap: dismissOnScrimTap ? close : null);
    add(scrim);
    panel = PositionComponent(size: designSize, anchor: Anchor.center);
    add(panel);
    _layout(game.size);
    scrim.opacity = 0;
    scrim.add(
      OpacityEffect.to(
        _scrimOpacity,
        EffectController(duration: _openDuration),
      ),
    );
    panel.scale = Vector2.zero();
    panel.add(
      ScaleEffect.to(
        _fitScale.clone(),
        EffectController(duration: _openDuration, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _layout(size);
    }
  }

  void close() {
    if (_closing) {
      return;
    }
    _closing = true;
    scrim.add(
      OpacityEffect.to(0, EffectController(duration: _closeDuration)),
    );
    panel.add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: _closeDuration, curve: Curves.easeIn),
        onComplete: game.router.pop,
      ),
    );
  }

  void _layout(Vector2 size) {
    panel.position = size / 2;
    final factor = min(
      1.0,
      min(0.92 * size.x / designSize.x, 0.92 * size.y / designSize.y),
    );
    _fitScale = Vector2.all(factor);
    final animating = panel.children.whereType<ScaleEffect>().isNotEmpty;
    if (!animating && !_closing) {
      panel.scale = _fitScale;
    }
  }
}
