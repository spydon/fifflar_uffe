import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/lightened_sprite_component.dart';
import 'package:flame/components.dart';

class PanelCloseButton extends AdvancedButtonComponent
    with HasGameReference<FifflarUffeGame> {
  PanelCloseButton({
    required void Function() onPressed,
    super.position,
    super.anchor,
    super.priority,
  }) : super(onPressed: onPressed, size: Vector2(56, 62));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    defaultSkin = SpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.buttonCompactWhite)),
    );
    downSkin = SpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.buttonCompactGray)),
    );
    hoverSkin = LightenedSpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.buttonCompactWhite)),
    );
    defaultLabel = SpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.iconClose)),
      size: Vector2.all(28),
    );
  }
}
