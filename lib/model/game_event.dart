import 'dart:convert';

import 'package:fifflar_uffe/services/i18n.dart';

class GameEvent {
  GameEvent({
    required this.id,
    required this.date,
    required this.source,
    required this.url,
    required this._title,
    required this._body,
  });

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);
    return GameEvent(
      id: json['id'] as String,
      date: DateTime.utc(date.year, date.month, date.day),
      source: json['source'] as String,
      url: json['url'] as String,
      title: (json['title'] as Map<String, dynamic>).cast<String, String>(),
      body: (json['body'] as Map<String, dynamic>).cast<String, String>(),
    );
  }

  final String id;
  final DateTime date;
  final String source;
  final String url;
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
      for (final event in eventsJson)
        GameEvent.fromJson(event as Map<String, dynamic>),
    ]);
  }

  final List<GameEvent> events;

  List<GameEvent> upTo(DateTime date) =>
      events.where((event) => !event.date.isAfter(date)).toList();
}
