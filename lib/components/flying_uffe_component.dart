import 'dart:math';

import 'package:fifflar_uffe/components/uffe_figure_component.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class FlyingUffeComponent extends PositionComponent
    with HasGameRef<FifflarUffeGame> {
  FlyingUffeComponent({
    required super.position,
    required this.velocity,
    required this.spin,
    required this.flapPhase,
    required double height,
  }) : _figure = UffeFigureComponent(height: height),
       super(anchor: Anchor.center) {
    size = _figure.size;
  }

  static const double _flapDistance = 14;
  static const double _flapSpeed = 16;
  static const double _popInDuration = 0.4;

  final Vector2 velocity;
  final double spin;
  final double flapPhase;
  final UffeFigureComponent _figure;

  double _age = 0;

  @override
  Future<void> onLoad() async {
    add(_figure);
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: _popInDuration, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    position += velocity * dt;
    angle += spin * dt;
    _bounceOffEdges();
    if (_figure.isLoaded) {
      final flap = 0.5 + 0.5 * sin(_age * _flapSpeed + flapPhase);
      _figure.head.position =
          _figure.headRestPosition - Vector2(0, _flapDistance * flap);
    }
  }

  void _bounceOffEdges() {
    final bounds = gameRef.size;
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;
    if ((position.x < halfWidth && velocity.x < 0) ||
        (position.x > bounds.x - halfWidth && velocity.x > 0)) {
      velocity.x = -velocity.x;
    }
    if ((position.y < halfHeight && velocity.y < 0) ||
        (position.y > bounds.y - halfHeight && velocity.y > 0)) {
      velocity.y = -velocity.y;
    }
  }
}
