import 'dart:ui';

import 'package:fifflar_uffe/ui/hover_lighten.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

class SwitchButton extends PositionComponent
    with TapCallbacks, HoverCallbacks, HoverLighten {
  SwitchButton({
    required this.value,
    super.position,
    super.anchor,
    super.priority,
  }) : super(size: Vector2(92, 44));

  static const double _padding = 5;
  static const double _slideDuration = 0.15;
  static const Color _onColor = Color(0xFF5CB85C);
  static const Color _offColor = Color(0xFFB9A68C);

  final ValueNotifier<bool> value;

  late final _SwitchTrack _track;
  late final CircleComponent _knob;

  double get _knobRadius => (size.y - 2 * _padding) / 2;

  Vector2 _knobPosition({required bool on}) => Vector2(
    on ? size.x - _padding - _knobRadius : _padding + _knobRadius,
    size.y / 2,
  );

  @override
  Future<void> onLoad() async {
    addAll([
      _track = _SwitchTrack(size: size.clone(), color: _trackColor),
      _knob = CircleComponent(
        radius: _knobRadius,
        anchor: Anchor.center,
        position: _knobPosition(on: value.value),
        paint: Paint()..color = const Color(0xFFFFF6E3),
      ),
    ]);
  }

  @override
  void onMount() {
    super.onMount();
    value.addListener(_animate);
  }

  @override
  void onRemove() {
    value.removeListener(_animate);
    super.onRemove();
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    const slack = 8.0;
    return point.x >= -slack &&
        point.x <= size.x + slack &&
        point.y >= -slack &&
        point.y <= size.y + slack;
  }

  @override
  void onTapUp(TapUpEvent event) {
    value.value = !value.value;
  }

  Color get _trackColor => value.value ? _onColor : _offColor;

  void _animate() {
    _track.color = _trackColor;
    for (final effect in _knob.children.whereType<MoveEffect>().toList()) {
      effect.removeFromParent();
    }
    _knob.add(
      MoveToEffect(
        _knobPosition(on: value.value),
        EffectController(duration: _slideDuration, curve: Curves.easeOut),
      ),
    );
  }
}

class _SwitchTrack extends PositionComponent {
  _SwitchTrack({required super.size, required this.color});

  static final Paint _outlinePaint = Paint()
    ..color = TextStyles.brown
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  Color color;

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(size.y / 2),
    );
    canvas.drawRRect(rect, Paint()..color = color);
    canvas.drawRRect(rect.deflate(2), _outlinePaint);
  }
}
