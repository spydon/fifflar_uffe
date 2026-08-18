import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart' hide Route;

class HudIconButton extends HudMarginComponent
    with HasGameReference<FifflarUffeGame> {
  HudIconButton({
    required this.iconPath,
    required EdgeInsets margin,
    required this.onPressed,
  }) : super(margin: margin);

  final String iconPath;
  final void Function() onPressed;

  @override
  Future<void> onLoad() async {
    size = Vector2(64, 72);
    add(
      AdvancedButtonComponent(
        size: size,
        defaultSkin: SpriteComponent(
          sprite: Sprite(game.images.fromCache(AssetPaths.buttonCompactWhite)),
        ),
        downSkin: SpriteComponent(
          sprite: Sprite(game.images.fromCache(AssetPaths.buttonCompactGray)),
        ),
        defaultLabel: SpriteComponent(
          sprite: Sprite(game.images.fromCache(iconPath)),
          size: Vector2.all(34),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
