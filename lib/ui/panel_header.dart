import 'dart:math';

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

  static const double _edgeInset = 45;

  final String Function(Strings strings) title;

  late final LocalizedTextComponent _text;

  @override
  Future<void> onLoad() async {
    add(
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.headerRibbon)),
        size: size,
      ),
    );
    _text = LocalizedTextComponent(
      selector: title,
      textRenderer: TextStyles.title,
      anchor: Anchor.center,
      position: size / 2 - Vector2(0, 6),
    );
    add(_text);
    _text.size.addListener(_fitText);
    _fitText();
  }

  void _fitText() {
    final maxWidth = size.x - 2 * _edgeInset;
    final textWidth = _text.size.x;
    final factor = textWidth > 0 ? min(1.0, maxWidth / textWidth) : 1.0;
    _text.scale = Vector2.all(factor);
  }
}
