import 'dart:math';

import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

class UffeFigureComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FifflarUffeGame> {
  UffeFigureComponent({required double height, this.onPoked})
    : super(size: Vector2(sourceWidth / sourceHeight * height, height));

  final VoidCallback? onPoked;

  static const double sourceWidth = 609;
  static const double sourceHeight = 1024;
  static const double _headSourceHeight = 200;
  static const double _bodySourceHeight = 811;

  static const double _gravity = 1400;
  static const double _minJumpHeight = 8;
  static const double _maxJumpHeight = 28;
  static const double _laughDuration = 0.7;
  static const double _laughFadeDuration = 0.3;
  static const double _laughFrequency = 11;
  static const double _laughBobDistance = 5;
  static const double _laughTiltAngle = 0.07;

  static final Random _random = Random();

  late final PositionComponent head;
  late final Vector2 headRestPosition;
  late final SpriteComponent _headSprite;
  late final Vector2 _headSpriteRestPosition;

  double _jumpVelocity = 0;
  double _laughRemaining = 0;
  double _laughPhase = 0;

  bool get isLaughing => _laughRemaining > 0;

  bool get isAirborne => position.y < 0;

  @override
  Future<void> onLoad() async {
    final scaleFactor = size.y / sourceHeight;
    final bodyTop = (sourceHeight - _bodySourceHeight) * scaleFactor;
    final headSize = Vector2(
      sourceWidth * scaleFactor,
      _headSourceHeight * scaleFactor,
    );
    headRestPosition = Vector2(sourceWidth * scaleFactor / 2, bodyTop);
    _headSpriteRestPosition = Vector2(headSize.x / 2, headSize.y);
    _headSprite = SpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.uffeHead)),
      size: headSize,
      anchor: Anchor.bottomCenter,
      position: _headSpriteRestPosition.clone(),
    );
    head = PositionComponent(
      size: headSize,
      anchor: Anchor.bottomCenter,
      position: headRestPosition.clone(),
      children: [_headSprite],
    );
    addAll([
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.uffeBody)),
        size: Vector2(
          sourceWidth * scaleFactor,
          _bodySourceHeight * scaleFactor,
        ),
        position: Vector2(0, bodyTop),
      ),
      head,
    ]);
  }

  @override
  void onTapDown(TapDownEvent event) {
    laugh();
    onPoked?.call();
  }

  void laugh() {
    final currentHeight = -position.y;
    final targetHeight = min(
      _maxJumpHeight,
      max(
        currentHeight + _minJumpHeight / 2,
        _minJumpHeight +
            _random.nextDouble() * (_maxJumpHeight - _minJumpHeight),
      ),
    );
    _jumpVelocity = -sqrt(2 * _gravity * max(0, targetHeight - currentHeight));
    _laughRemaining = _laughDuration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateJump(dt);
    _updateLaugh(dt);
  }

  void _updateJump(double dt) {
    if (!isAirborne && _jumpVelocity == 0) {
      return;
    }
    position.y += _jumpVelocity * dt;
    _jumpVelocity += _gravity * dt;
    if (position.y >= 0) {
      position.y = 0;
      _jumpVelocity = 0;
    }
  }

  void _updateLaugh(double dt) {
    if (!isLaughing) {
      return;
    }
    _laughRemaining = max(0, _laughRemaining - dt);
    _laughPhase += dt * _laughFrequency * 2 * pi;
    final envelope = min(1, _laughRemaining / _laughFadeDuration);
    final wave = sin(_laughPhase);
    _headSprite.position.y =
        _headSpriteRestPosition.y -
        envelope * (1 + wave) / 2 * _laughBobDistance;
    _headSprite.angle = envelope * wave * _laughTiltAngle;
    if (!isLaughing) {
      _laughPhase = 0;
      _headSprite.position.setFrom(_headSpriteRestPosition);
      _headSprite.angle = 0;
    }
  }
}
