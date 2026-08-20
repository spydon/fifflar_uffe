import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

class ButtonSpinner extends PositionComponent {
  ButtonSpinner({double diameter = 36}) : super(size: Vector2.all(diameter));

  static const double _turnsPerSecond = 1.1;
  static const double _sweep = pi * 1.4;
  static const double _strokeWidth = 5;

  final Paint _track = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth
    ..color = const Color(0x40000000);
  final Paint _arc = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFFFFF6E3);

  double _startAngle = 0;

  @override
  void update(double dt) {
    _startAngle = (_startAngle + dt * _turnsPerSecond * 2 * pi) % (2 * pi);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(
      _strokeWidth / 2,
      _strokeWidth / 2,
      size.x - _strokeWidth,
      size.y - _strokeWidth,
    );
    canvas
      ..drawOval(rect, _track)
      ..drawArc(rect, _startAngle, _sweep, false, _arc);
  }
}
