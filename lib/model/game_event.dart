import 'dart:convert';

import 'package:fifflar_uffe/services/i18n.dart';

class EventSource {
  const EventSource({required this.name, required this.url});

  factory EventSource.fromJson(Map<String, dynamic> json) =>
      EventSource(name: json['name'] as String, url: json['url'] as String);

  final String name;
  final String url;
}

class GameEvent {
  GameEvent({
    required this.id,
    required this.date,
    required this.sources,
    required this._title,
    required this._body,
  });

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['game_date'] as String);
    return GameEvent(
      id: json['id'] as String,
      date: DateTime.utc(date.year, date.month, date.day),
      sources: [
        for (final source in json['sources'] as List<dynamic>)
          EventSource.fromJson(source as Map<String, dynamic>),
      ],
      title: (json['title'] as Map<String, dynamic>).cast<String, String>(),
      body: (json['body'] as Map<String, dynamic>).cast<String, String>(),
    );
  }

  final String id;
  final DateTime date;

  /// Every source backing the event. The game shows only the first one;
  /// the references page on the website lists them all.
  final List<EventSource> sources;

  String get source => sources.first.name;

  String get url => sources.first.url;

  final Map<String, String> _title;
  final Map<String, String> _body;

  String title(AppLanguage language) =>
      _title[language.name] ?? _title[AppLanguage.sv.name] ?? '';

  String body(AppLanguage language) =>
      _body[language.name] ?? _body[AppLanguage.sv.name] ?? '';
}

class EventCatalog {
  EventCatalog(Iterable<GameEvent> events) : events = _sorted(events);

  static List<GameEvent> _sorted(Iterable<GameEvent> events) {
    final sorted = events.toList()..sort((a, b) => a.date.compareTo(b.date));
    return List.unmodifiable(sorted);
  }

  factory EventCatalog.fromJsonString(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final eventsJson = json['events'] as List<dynamic>;
    return EventCatalog([
      for (final event in eventsJson.cast<Map<String, dynamic>>())
        if (event['game_date'] != null) GameEvent.fromJson(event),
    ]);
  }

  final List<GameEvent> events;

  List<GameEvent> upTo(DateTime date) =>
      events.where((event) => !event.date.isAfter(date)).toList();
}
