import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/strings.dart';
import 'package:flame/components.dart';

class LocalizedTextBoxComponent extends TextBoxComponent
    with HasGameReference<FifflarUffeGame> {
  LocalizedTextBoxComponent({
    required this.selector,
    super.textRenderer,
    super.boxConfig,
    super.align,
    super.position,
    super.anchor,
    super.priority,
  });

  final String Function(Strings strings) selector;

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

  void _refresh() {
    text = selector(game.i18n.strings);
  }
}
