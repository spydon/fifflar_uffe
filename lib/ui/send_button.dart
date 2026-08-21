import 'dart:ui';

import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/hover_lighten.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';

class SendButton extends AdvancedButtonComponent
    with HasGameReference<FifflarUffeGame>, HoverLighten {
  SendButton({
    required void Function() onPressed,
    super.position,
    super.anchor,
    super.priority,
  }) : super(onPressed: onPressed, size: Vector2(62, 68));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    defaultSkin = SpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.buttonCompactWhite)),
    );
    downSkin = SpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.buttonCompactGray)),
    );
    disabledSkin = SpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.buttonCompactGray)),
    );
    defaultLabel = _ArrowIcon(size: Vector2.all(30));
  }
}

class _ArrowIcon extends PositionComponent {
  _ArrowIcon({required super.size});

  static final Paint _paint = Paint()
    ..color = TextStyles.brown
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void render(Canvas canvas) {
    final middle = size.y / 2;
    final path = Path()
      ..moveTo(3, middle)
      ..lineTo(size.x - 4, middle)
      ..moveTo(size.x / 2 + 2, 4)
      ..lineTo(size.x - 4, middle)
      ..lineTo(size.x / 2 + 2, size.y - 4);
    canvas.drawPath(path, _paint);
  }
}
