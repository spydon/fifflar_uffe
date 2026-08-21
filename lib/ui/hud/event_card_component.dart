import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/game_event.dart';
import 'package:fifflar_uffe/ui/panel_close_button.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/non_breaking_numbers.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';
import 'package:url_launcher/url_launcher.dart';

class EventCardComponent extends PositionComponent
    with HasGameReference<FifflarUffeGame>, TapCallbacks {
  EventCardComponent({required this.event}) : super(size: Vector2(320, 172));

  static const double _displayDuration = 15;
  static const double _padding = 20;

  final GameEvent event;

  late final PanelComponent _panel;
  late final TextBoxComponent _title;
  late final TextBoxComponent _body;
  late final _EventLink _link;
  bool _dismissing = false;

  bool get isDismissing => _dismissing;

  @override
  Future<void> onLoad() async {
    final textWidth = size.x - 2 * _padding;
    addAll([
      _panel = PanelComponent(size: size * 2)..scale = Vector2.all(0.5),
      _title = TextBoxComponent(
        textRenderer: TextStyles.eventTitle,
        boxConfig: TextBoxConfig(maxWidth: textWidth - 24),
        position: Vector2(_padding, 12),
      ),
      _body = TextBoxComponent(
        textRenderer: TextStyles.eventBody,
        boxConfig: TextBoxConfig(maxWidth: textWidth),
        position: Vector2(_padding, 44),
      ),
      _link = _EventLink(
        text: event.source,
        url: event.url,
        position: Vector2(_padding + 8, 132),
      ),
      PanelCloseButton(
        position: Vector2(size.x - 10, 12),
        anchor: Anchor.center,
        onPressed: _slideAway,
      )..scale = Vector2.all(0.55),
      TimerComponent(
        period: _displayDuration,
        removeOnFinish: true,
        onTick: _dismiss,
      ),
    ]);
    _title.size.addListener(_layoutContent);
    _body.size.addListener(_layoutContent);
    _layoutContent();
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.3, curve: Curves.easeOutBack),
      ),
    );
  }

  void _layoutContent() {
    _body.position = Vector2(
      _padding,
      _title.position.y + _title.size.y - 4,
    );
    _link.position = Vector2(
      _padding + 8,
      _body.position.y + _body.size.y + 2,
    );
    size = Vector2(size.x, _link.position.y + _link.size.y + 6);
    _panel.size = size * 2;
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
    _title.text = nonBreakingNumbers(event.title(language));
    _body.text = nonBreakingNumbers(event.body(language));
  }

  @override
  void onTapUp(TapUpEvent event) {
    _slideAway();
  }

  void _slideAway() {
    if (_dismissing) {
      return;
    }
    _dismissing = true;
    add(
      MoveEffect.by(
        Vector2(-(size.x + 60), 0),
        EffectController(duration: 0.35, curve: Curves.easeInBack),
        onComplete: removeFromParent,
      ),
    );
  }

  void _dismiss() {
    if (_dismissing) {
      return;
    }
    _dismissing = true;
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
