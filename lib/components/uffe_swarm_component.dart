import 'dart:math';

import 'package:fifflar_uffe/components/flying_uffe_component.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/hud/hud_auto_scale.dart';
import 'package:flame/components.dart';

class UffeSwarmComponent extends Component
    with HasGameReference<FifflarUffeGame> {
  UffeSwarmComponent({this.count = 48, super.priority});

  static const double _spawnInterval = 0.05;
  static const double _minHeight = 100;
  static const double _maxHeight = 240;
  static const double _minSpeed = 120;
  static const double _maxSpeed = 340;
  static const double _maxSpin = 3;
  static final Random _random = Random();

  final int count;

  double _untilNextSpawn = 0;
  int _spawned = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (_spawned >= count) {
      return;
    }
    _untilNextSpawn -= dt;
    while (_untilNextSpawn <= 0 && _spawned < count) {
      _spawn();
      _untilNextSpawn += _spawnInterval;
    }
  }

  void _spawn() {
    final screen = game.size;
    final hudScale = HudAutoScale.factorFor(screen);
    final direction = _random.nextDouble() * 2 * pi;
    final speed = _minSpeed + _random.nextDouble() * (_maxSpeed - _minSpeed);
    add(
      FlyingUffeComponent(
        position: Vector2(
          _random.nextDouble() * screen.x,
          _random.nextDouble() * screen.y,
        ),
        velocity: Vector2(cos(direction), sin(direction)) * speed,
        spin: (_random.nextDouble() * 2 - 1) * _maxSpin,
        flapPhase: _random.nextDouble() * 2 * pi,
        height:
            (_minHeight + _random.nextDouble() * (_maxHeight - _minHeight)) *
            hudScale,
      ),
    );
    _spawned++;
  }
}
