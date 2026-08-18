import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/speech_bubble_component.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart' hide Route;

class UffeComponent extends HudMarginComponent
    with HasGameReference<FifflarUffeGame> {
  UffeComponent({super.priority})
    : super(margin: const EdgeInsets.only(left: 12));

  late final SpeechBubbleComponent _bubble;

  @override
  Future<void> onLoad() async {
    size = Vector2(132, 222);
    add(
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.uffe)),
        size: size,
      ),
    );
    _bubble = SpeechBubbleComponent(
      position: Vector2(size.x * 0.55, 10),
      anchor: Anchor.bottomLeft,
    );
    add(_bubble);
  }

  void say(String message) {
    _bubble.say(message);
  }
}
