import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/game_event.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';
import 'package:url_launcher/url_launcher.dart';

class EventCardComponent extends PositionComponent
    with HasGameReference<FifflarUffeGame> {
  EventCardComponent({required this.event}) : super(size: Vector2(320, 156));

  static const double _displayDuration = 15;
  static const double _padding = 20;

  final GameEvent event;

  late final TextBoxComponent _title;
  late final TextBoxComponent _body;

  @override
  Future<void> onLoad() async {
    final textWidth = size.x - 2 * _padding;
    addAll([
      PanelComponent(size: size),
      _title = TextBoxComponent(
        textRenderer: TextStyles.eventTitle,
        boxConfig: TextBoxConfig(maxWidth: textWidth),
        position: Vector2(_padding, 10),
      ),
      _body = TextBoxComponent(
        textRenderer: TextStyles.eventBody,
        boxConfig: TextBoxConfig(maxWidth: textWidth),
        position: Vector2(_padding, 42),
      ),
      _EventLink(
        text: event.source,
        url: event.url,
        position: Vector2(_padding, size.y - 40),
      ),
      TimerComponent(
        period: _displayDuration,
        removeOnFinish: true,
        onTick: _dismiss,
      ),
    ]);
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.3, curve: Curves.easeOutBack),
      ),
    );
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

  void _refresh() {
    final language = game.i18n.language.value;
    _title.text = event.title(language);
    _body.text = event.body(language);
  }

  void _dismiss() {
    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.25, curve: Curves.easeIn),
        onComplete: removeFromParent,
      ),
    );
  }
}

class _EventLink extends PositionComponent with TapCallbacks {
  _EventLink({required String text, required this.url, super.position})
    : super(size: Vector2(220, 30)) {
    _link = TextComponent(text: text, textRenderer: TextStyles.eventLink);
  }

  final String url;
  late final TextComponent _link;

  @override
  Future<void> onLoad() async {
    add(_link);
  }

  @override
  void onTapUp(TapUpEvent event) {
    launchUrl(Uri.parse(url));
  }
}
