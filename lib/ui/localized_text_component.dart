import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/strings.dart';
import 'package:flame/components.dart';

class LocalizedTextComponent extends TextComponent
    with HasGameRef<FifflarUffeGame> {
  LocalizedTextComponent({
    required this.selector,
    super.textRenderer,
    super.position,
    super.anchor,
    super.priority,
  });

  final String Function(Strings strings) selector;

  @override
  void onMount() {
    super.onMount();
    _refresh();
    gameRef.i18n.language.addListener(_refresh);
  }

  @override
  void onRemove() {
    gameRef.i18n.language.removeListener(_refresh);
    super.onRemove();
  }

  void _refresh() {
    text = selector(gameRef.i18n.strings);
  }
}
