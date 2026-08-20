import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';

class UffeFigureComponent extends PositionComponent
    with HasGameReference<FifflarUffeGame> {
  UffeFigureComponent({required double height})
    : super(size: Vector2(sourceWidth / sourceHeight * height, height));

  static const double sourceWidth = 609;
  static const double sourceHeight = 1024;
  static const double _headSourceHeight = 200;
  static const double _bodySourceHeight = 811;

  late final SpriteComponent head;
  late final Vector2 headRestPosition;

  @override
  Future<void> onLoad() async {
    final scaleFactor = size.y / sourceHeight;
    final bodyTop = (sourceHeight - _bodySourceHeight) * scaleFactor;
    headRestPosition = Vector2(sourceWidth * scaleFactor / 2, bodyTop);
    head = SpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.uffeHead)),
      size: Vector2(sourceWidth * scaleFactor, _headSourceHeight * scaleFactor),
      anchor: Anchor.bottomCenter,
      position: headRestPosition.clone(),
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
}
