import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/hover_lighten.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class ToggleButton extends AdvancedButtonComponent
    with HasGameReference<FifflarUffeGame>, HoverLighten {
  ToggleButton({
    required this.value,
    super.position,
    super.anchor,
    super.priority,
  }) : super(size: Vector2(54, 56));

  final ValueNotifier<bool> value;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    onPressed = () => value.value = !value.value;
    _applySkins();
  }

  @override
  void onMount() {
    super.onMount();
    value.addListener(_applySkins);
  }

  @override
  void onRemove() {
    value.removeListener(_applySkins);
    super.onRemove();
  }

  void _applySkins() {
    final path = value.value
        ? AssetPaths.radioChecked
        : AssetPaths.radioUnchecked;
    defaultSkin = SpriteComponent(
      sprite: Sprite(game.images.fromCache(path)),
    );
    downSkin = SpriteComponent(
      sprite: Sprite(game.images.fromCache(path)),
    );
    invalidateSkins();
  }
}
