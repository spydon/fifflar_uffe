import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/speech_bubble_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart' hide Route;

class UffeComponent extends HudMarginComponent
    with HasGameReference<FifflarUffeGame> {
  UffeComponent({super.priority})
    : super(margin: const EdgeInsets.only(left: 12));

  static const double _sourceWidth = 609;
  static const double _sourceHeight = 1024;
  static const double _headSourceHeight = 200;
  static const double _bodySourceHeight = 811;
  static const double _flapDistance = 14;

  late final SpeechBubbleComponent _bubble;
  late final SpriteComponent _head;
  late final Vector2 _headRestPosition;
  Effect? _flap;

  @override
  Future<void> onLoad() async {
    size = Vector2(132, 222);
    final scaleFactor = size.y / _sourceHeight;
    final bodyTop = (_sourceHeight - _bodySourceHeight) * scaleFactor;
    _headRestPosition = Vector2(0, bodyTop - _headSourceHeight * scaleFactor);
    _head = SpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.uffeHead)),
      size: Vector2(
        _sourceWidth * scaleFactor,
        _headSourceHeight * scaleFactor,
      ),
      position: _headRestPosition.clone(),
    );
    addAll([
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.uffeBody)),
        size: Vector2(
          _sourceWidth * scaleFactor,
          _bodySourceHeight * scaleFactor,
        ),
        position: Vector2(0, bodyTop),
      ),
      _head,
    ]);
    _bubble = SpeechBubbleComponent(
      position: Vector2(size.x * 0.55, 10),
      anchor: Anchor.bottomLeft,
      onTalkingChanged: _setTalking,
    );
    add(_bubble);
  }

  void say(String message) {
    _bubble.say(message);
  }

  void _setTalking({required bool talking}) {
    _flap?.removeFromParent();
    _flap = null;
    _head.position = _headRestPosition.clone();
    if (talking) {
      _flap = MoveByEffect(
        Vector2(0, -_flapDistance),
        EffectController(duration: 0.09, alternate: true, infinite: true),
      );
      _head.add(_flap!);
    }
  }
}
