import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/strings.dart';
import 'package:fifflar_uffe/ui/localized_text_component.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';

class PanelHeader extends PositionComponent
    with HasGameReference<FifflarUffeGame> {
  PanelHeader({
    required this.title,
    required Vector2 size,
    super.position,
    super.anchor,
    super.priority,
  }) : super(size: size);

  final String Function(Strings strings) title;

  @override
  Future<void> onLoad() async {
    add(
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.headerRibbon)),
        size: size,
      ),
    );
    add(
      LocalizedTextComponent(
        selector: title,
        textRenderer: TextStyles.title,
        anchor: Anchor.center,
        position: size / 2 - Vector2(0, 6),
      ),
    );
  }
}
