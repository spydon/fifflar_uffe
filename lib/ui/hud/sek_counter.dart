import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/hud/hud_auto_scale.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart' hide Route;

class SekCounter extends HudMarginComponent
    with HasGameReference<FifflarUffeGame>, HudAutoScale {
  SekCounter() : super(margin: const EdgeInsets.only(top: 12, right: 12));

  static const double _notchInset = 12;

  late final TextComponent _text;
  late final TextComponent _incomeText;

  @override
  Future<void> onLoad() async {
    size = Vector2(240, 56);
    add(
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.labelPill)),
        size: size,
      ),
    );
    _text = TextComponent(
      textRenderer: TextStyles.counter,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_text);
    final incomePill = SpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.labelPill)),
      size: Vector2(size.x, 36),
      position: Vector2(0, size.y + 4),
    );
    _incomeText = TextComponent(
      textRenderer: TextStyles.subCounter,
      anchor: Anchor.center,
      position: incomePill.size / 2,
    );
    incomePill.add(_incomeText);
    add(incomePill);
  }

  @override
  void onMount() {
    super.onMount();
    _refresh();
    game.economy.addListener(_refresh);
  }

  @override
  void onRemove() {
    game.economy.removeListener(_refresh);
    super.onRemove();
  }

  void _refresh() {
    _text.text = formatSek(game.economy.balance);
    _incomeText.text = '+${formatSek(game.economy.incomePerSecond)}/s';
    if (_text.size.x > size.x - 2 * _notchInset) {
      game.handleBalanceOverflow();
    }
  }
}
