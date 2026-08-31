import 'dart:math';

import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/game_event.dart';
import 'package:fifflar_uffe/ui/hud/event_card_component.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart' hide Route;

class EventFeedComponent extends HudMarginComponent
    with HasGameRef<FifflarUffeGame> {
  EventFeedComponent()
    : super(margin: const EdgeInsets.only(top: 80, left: 12));

  static const double minReadTime = 6;

  final Set<String> _consumed = {};
  final List<GameEvent> _queue = [];
  double _shownFor = 0;

  List<GameEvent> get queuedEvents => List.unmodifiable(_queue);

  EventCardComponent? _current;

  bool get _showingCard {
    final current = _current;
    return current != null && current.parent == this && !current.isDismissing;
  }

  @override
  void onGameResize(Vector2 size) {
    scale = Vector2.all(min(1, (size.x - 24) / 320));
    super.onGameResize(size);
  }

  @override
  Future<void> onLoad() async {
    size = Vector2(320, 172);
  }

  @override
  void onMount() {
    super.onMount();
    for (final event in gameRef.eventCatalog.upTo(
      gameRef.timeline.currentDate,
    )) {
      _consumed.add(event.id);
    }
    gameRef.timeline.addListener(_checkEvents);
  }

  @override
  void onRemove() {
    gameRef.timeline.removeListener(_checkEvents);
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _shownFor += dt;
    _showNextIfReady();
  }

  void resetRun() {
    _consumed.clear();
    _queue.clear();
    _current = null;
    _shownFor = 0;
    for (final card in children.whereType<EventCardComponent>().toList()) {
      card.removeFromParent();
    }
  }

  void _checkEvents() {
    for (final event in gameRef.eventCatalog.upTo(
      gameRef.timeline.currentDate,
    )) {
      if (_consumed.add(event.id)) {
        _queue.add(event);
      }
    }
    _showNextIfReady();
  }

  void _showNextIfReady() {
    if (_queue.isEmpty) {
      return;
    }
    if (_showingCard && _shownFor < minReadTime) {
      return;
    }
    _show(_queue.removeAt(0));
  }

  void _show(GameEvent event) {
    for (final card in children.whereType<EventCardComponent>().toList()) {
      card.removeFromParent();
    }
    final card = EventCardComponent(event: event);
    add(card);
    _current = card;
    _shownFor = 0;
  }
}
