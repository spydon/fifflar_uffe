import 'dart:math';

import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';

class BackgroundComponent extends SpriteComponent
    with HasGameRef<FifflarUffeGame> {
  BackgroundComponent() : super(anchor: Anchor.center, priority: -1);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(gameRef.images.fromCache(AssetPaths.background));
    opacity = 0.35;
    _cover(gameRef.size);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (isLoaded) {
      _cover(gameSize);
    }
  }

  void _cover(Vector2 gameSize) {
    final imageSize = sprite!.originalSize;
    final scaleFactor = max(
      gameSize.x / imageSize.x,
      gameSize.y / imageSize.y,
    );
    size = imageSize * scaleFactor;
    position = gameSize / 2;
  }
}
