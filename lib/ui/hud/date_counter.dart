import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/hud/hud_auto_scale.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart' hide Route;

class DateCounter extends HudMarginComponent
    with HasGameRef<FifflarUffeGame>, HudAutoScale {
  DateCounter() : super(margin: const EdgeInsets.only(top: 12, left: 12));

  late final TextComponent _text;

  @override
  Future<void> onLoad() async {
    size = Vector2(200, 56);
    add(
      SpriteComponent(
        sprite: Sprite(gameRef.images.fromCache(AssetPaths.labelPill)),
        size: size,
      ),
    );
    _text = TextComponent(
      textRenderer: TextStyles.counter,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_text);
  }

  @override
  void onMount() {
    super.onMount();
    _refresh();
    gameRef.timeline.addListener(_refresh);
    gameRef.i18n.language.addListener(_refresh);
  }

  @override
  void onRemove() {
    gameRef.timeline.removeListener(_refresh);
    gameRef.i18n.language.removeListener(_refresh);
    super.onRemove();
  }

  void _refresh() {
    _text.text = gameRef.i18n.strings.formatDate(gameRef.timeline.currentDate);
  }
}
