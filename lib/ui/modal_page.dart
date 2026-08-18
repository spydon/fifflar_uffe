import 'dart:math';

import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/scrim_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

abstract class ModalPage extends PositionComponent
    with HasGameReference<FifflarUffeGame> {
  ModalPage({required this.designSize, this.dismissOnScrimTap = true});

  final Vector2 designSize;
  final bool dismissOnScrimTap;

  late final PositionComponent panel;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    add(
      ScrimComponent(
        onTap: dismissOnScrimTap ? () => game.router.pop() : null,
      ),
    );
    panel = PositionComponent(size: designSize, anchor: Anchor.center);
    add(panel);
    _layout(game.size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _layout(size);
    }
  }

  void _layout(Vector2 size) {
    panel.position = size / 2;
    final factor = min(
      1.0,
      min(0.92 * size.x / designSize.x, 0.92 * size.y / designSize.y),
    );
    panel.scale = Vector2.all(factor);
  }
}
