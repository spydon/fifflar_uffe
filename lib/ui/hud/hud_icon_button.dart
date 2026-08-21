import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/lightened_sprite_component.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
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

  static final Paint _outlinePaint = Paint()
    ..colorFilter = const ColorFilter.mode(TextStyles.brown, BlendMode.srcIn);

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
        hoverSkin: LightenedSpriteComponent(
          sprite: Sprite(game.images.fromCache(AssetPaths.buttonCompactWhite)),
        ),
        defaultLabel: _OutlinedIcon(
          sprite: Sprite(game.images.fromCache(iconPath)),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _OutlinedIcon extends PositionComponent {
  _OutlinedIcon({required Sprite sprite}) : super(size: Vector2.all(40)) {
    addAll([
      SpriteComponent(
        sprite: sprite,
        size: Vector2.all(40),
        anchor: Anchor.center,
        position: size / 2,
        paint: HudIconButton._outlinePaint,
      ),
      SpriteComponent(
        sprite: sprite,
        size: Vector2.all(32),
        anchor: Anchor.center,
        position: size / 2,
      ),
    ]);
  }
}
