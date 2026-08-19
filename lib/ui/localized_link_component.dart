import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/strings.dart';
import 'package:fifflar_uffe/ui/localized_text_component.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:url_launcher/url_launcher.dart';

class LocalizedLinkComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FifflarUffeGame> {
  LocalizedLinkComponent({
    required this.selector,
    required this.url,
    super.position,
    super.anchor,
    super.priority,
  });

  final String Function(Strings strings) selector;
  final String url;

  late final LocalizedTextComponent _text;

  @override
  Future<void> onLoad() async {
    _text = LocalizedTextComponent(
      selector: selector,
      textRenderer: TextStyles.eventLink,
    );
    _text.size.addListener(() => size.setFrom(_text.size));
    add(_text);
  }

  @override
  void onTapUp(TapUpEvent event) {
    launchUrl(Uri.base.resolve(url));
  }
}
