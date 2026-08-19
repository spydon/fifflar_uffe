import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/game_event.dart';
import 'package:fifflar_uffe/ui/hud/event_card_component.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart' hide Route;

class EventFeedComponent extends HudMarginComponent
    with HasGameReference<FifflarUffeGame> {
  EventFeedComponent()
    : super(margin: const EdgeInsets.only(top: 80, left: 12));

  final Set<String> _consumed = {};

  @override
  Future<void> onLoad() async {
    size = Vector2(320, 140);
  }

  @override
  void onMount() {
    super.onMount();
    for (final event in game.eventCatalog.upTo(game.timeline.currentDate)) {
      _consumed.add(event.id);
    }
    game.timeline.addListener(_checkEvents);
  }

  @override
  void onRemove() {
    game.timeline.removeListener(_checkEvents);
    super.onRemove();
  }

  void resetRun() {
    _consumed.clear();
    for (final card in children.whereType<EventCardComponent>().toList()) {
      card.removeFromParent();
    }
  }

  void _checkEvents() {
    for (final event in game.eventCatalog.upTo(game.timeline.currentDate)) {
      if (_consumed.add(event.id)) {
        _show(event);
      }
    }
  }

  void _show(GameEvent event) {
    for (final card in children.whereType<EventCardComponent>().toList()) {
      card.removeFromParent();
    }
    add(EventCardComponent(event: event));
  }
}
