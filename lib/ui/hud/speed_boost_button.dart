import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/hover_lighten.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart' hide Route;

class SpeedBoostButton extends HudMarginComponent
    with HasGameRef<FifflarUffeGame> {
  SpeedBoostButton({required EdgeInsets margin}) : super(margin: margin);

  static const Color idleColor = Color(0xFFFFF6E3);
  static const Color activeColor = Color(0xFF5CB85C);

  late final _SpeedBoostToggle _toggle;

  bool get isActive => _toggle.isSelected;

  @override
  Future<void> onLoad() async {
    size = Vector2(64, 72);
    _toggle = _SpeedBoostToggle(
      size: size,
      defaultSkin: SpriteComponent(
        sprite: Sprite(gameRef.images.fromCache(AssetPaths.buttonCompactWhite)),
      ),
      downSkin: SpriteComponent(
        sprite: Sprite(gameRef.images.fromCache(AssetPaths.buttonCompactGray)),
      ),
      defaultSelectedSkin: SpriteComponent(
        sprite: Sprite(gameRef.images.fromCache(AssetPaths.buttonCompactGray)),
      ),
      downAndSelectedSkin: SpriteComponent(
        sprite: Sprite(gameRef.images.fromCache(AssetPaths.buttonCompactWhite)),
      ),
      defaultLabel: FastForwardIcon(color: idleColor),
      defaultSelectedLabel: FastForwardIcon(color: activeColor, pressed: true),
      onSelectedChanged: (selected) => gameRef.speedBoost.value = selected,
    );
    add(_toggle);
  }

  @override
  void onMount() {
    super.onMount();
    gameRef.speedBoost.addListener(_sync);
    _sync();
  }

  @override
  void onRemove() {
    gameRef.speedBoost.removeListener(_sync);
    super.onRemove();
  }

  void _sync() {
    _toggle.isSelected = gameRef.speedBoost.value;
  }
}

class _SpeedBoostToggle extends ToggleButtonComponent with HoverLighten {
  _SpeedBoostToggle({
    required super.size,
    required super.defaultSkin,
    required super.downSkin,
    required super.defaultSelectedSkin,
    required super.downAndSelectedSkin,
    required super.defaultLabel,
    required super.defaultSelectedLabel,
    required super.onSelectedChanged,
  });
}

class FastForwardIcon extends PositionComponent {
  FastForwardIcon({required Color color, this.pressed = false})
    : _fillPaint = Paint()..color = color,
      super(size: Vector2.all(40));

  static const double _chevronWidth = 15;
  static const double _chevronHeight = 26;
  static const double _gap = 2;
  static const double _pressOffset = 2;

  static final Paint _outlinePaint = Paint()
    ..color = TextStyles.brown
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeJoin = StrokeJoin.round;

  final Paint _fillPaint;
  final bool pressed;

  late final Path _path = _buildPath();

  Path _buildPath() {
    const totalWidth = 2 * _chevronWidth + _gap;
    final left = (size.x - totalWidth) / 2;
    final top = (size.y - _chevronHeight) / 2 + (pressed ? _pressOffset : 0);
    final path = Path();
    for (final x in [left, left + _chevronWidth + _gap]) {
      path
        ..moveTo(x, top)
        ..lineTo(x + _chevronWidth, top + _chevronHeight / 2)
        ..lineTo(x, top + _chevronHeight)
        ..close();
    }
    return path;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(_path, _outlinePaint);
    canvas.drawPath(_path, _fillPaint);
  }
}
