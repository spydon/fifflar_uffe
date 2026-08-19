import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/speech_bubble_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart' hide Route;

class UffeComponent extends HudMarginComponent
    with HasGameReference<FifflarUffeGame> {
  UffeComponent()
    : super(margin: const EdgeInsets.only(left: 12), priority: restPriority);

  static const int restPriority = -1;
  static const double _sourceWidth = 609;
  static const double _sourceHeight = 1024;
  static const double _headSourceHeight = 200;
  static const double _bodySourceHeight = 811;
  static const double _flapDistance = 14;
  static const double _wobbleAngle = 0.1;
  static const double _leanDistance = 26;

  late final SpeechBubbleComponent _bubble;
  late final SpriteComponent _head;
  late final Vector2 _headRestPosition;
  final List<Effect> _talkEffects = [];
  final List<Effect> _leanEffects = [];
  Vector2? _restPosition;

  @override
  Future<void> onLoad() async {
    size = Vector2(132, 222);
    final scaleFactor = size.y / _sourceHeight;
    final bodyTop = (_sourceHeight - _bodySourceHeight) * scaleFactor;
    _headRestPosition = Vector2(_sourceWidth * scaleFactor / 2, bodyTop);
    _head = SpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.uffeHead)),
      size: Vector2(
        _sourceWidth * scaleFactor,
        _headSourceHeight * scaleFactor,
      ),
      anchor: Anchor.bottomCenter,
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
      position: Vector2(106, 36),
      anchor: Anchor.bottomLeft,
      onTalkingChanged: _setTalking,
    );
    add(_bubble);
  }

  void say(String message) {
    _bubble.say(message);
  }

  void _setTalking({required bool talking}) {
    for (final effect in _talkEffects) {
      effect.removeFromParent();
    }
    _talkEffects.clear();
    _head.position = _headRestPosition.clone();
    _head.angle = 0;
    final wasLeaning = _leanEffects.isNotEmpty;
    for (final effect in _leanEffects) {
      effect.removeFromParent();
    }
    _leanEffects.clear();
    if (talking) {
      _head.angle = -_wobbleAngle / 2;
      _talkEffects.addAll([
        MoveByEffect(
          Vector2(0, -_flapDistance),
          EffectController(duration: 0.09, alternate: true, infinite: true),
        ),
        RotateEffect.by(
          _wobbleAngle,
          EffectController(duration: 0.14, alternate: true, infinite: true),
        ),
      ]);
      _head.addAll(_talkEffects);
      if (!wasLeaning) {
        _restPosition = position.clone();
      }
      priority = game.router.priority + 1;
      final lean = MoveToEffect(
        _restPosition! - Vector2(0, _leanDistance),
        EffectController(duration: 0.25, curve: Curves.easeOutBack),
      );
      _leanEffects.add(lean);
      add(lean);
    } else {
      final restPosition = _restPosition;
      if (restPosition == null) {
        priority = restPriority;
        return;
      }
      final leanBack = MoveToEffect(
        restPosition.clone(),
        EffectController(duration: 0.25, curve: Curves.easeIn),
        onComplete: () => priority = restPriority,
      );
      _leanEffects.add(leanBack);
      add(leanBack);
    }
  }
}
