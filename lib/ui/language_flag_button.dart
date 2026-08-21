import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/i18n.dart';
import 'package:fifflar_uffe/ui/hover_lighten.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

class LanguageFlagButton extends PositionComponent
    with
        TapCallbacks,
        HoverCallbacks,
        HoverLighten,
        HasGameReference<FifflarUffeGame> {
  LanguageFlagButton({required this.language, super.position, super.anchor})
    : super(size: Vector2(96, 60));

  final AppLanguage language;

  late final SpriteComponent _flag;
  late final RectangleComponent _border;

  @override
  Future<void> onLoad() async {
    final flagPath = switch (language) {
      AppLanguage.sv => AssetPaths.flagSwedish,
      AppLanguage.en => AssetPaths.flagEnglish,
    };
    addAll([
      _border = RectangleComponent(
        size: size + Vector2.all(12),
        position: Vector2.all(-6),
        paint: Paint()
          ..color = TextStyles.brown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      ),
      _flag = SpriteComponent(
        sprite: Sprite(game.images.fromCache(flagPath)),
        size: size,
      ),
    ]);
  }

  @override
  void onMount() {
    super.onMount();
    _refresh();
    game.i18n.language.addListener(_refresh);
  }

  @override
  void onRemove() {
    game.i18n.language.removeListener(_refresh);
    super.onRemove();
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    const slack = 10.0;
    return point.x >= -slack &&
        point.x <= size.x + slack &&
        point.y >= -slack &&
        point.y <= size.y + slack;
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.i18n.language.value = language;
  }

  void _refresh() {
    final selected = game.i18n.language.value == language;
    _border.setOpacity(selected ? 1 : 0);
    _flag.opacity = selected ? 1 : 0.4;
  }
}
