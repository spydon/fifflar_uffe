import 'package:fifflar_uffe/model/game_event.dart';
import 'package:fifflar_uffe/services/i18n.dart';
import 'package:flutter_test/flutter_test.dart';

const _catalogJson = '''
{
  "events": [
    {
      "id": "second",
      "date": "2001-06-01",
      "sources": [
        {"name": "Dagens Arena", "url": "https://example.com/second"},
        {"name": "Wikipedia", "url": "https://example.com/more"}
      ],
      "title": {"sv": "Svart städhjälp", "en": "Undeclared cleaning help"},
      "body": {"sv": "Uffe fifflar.", "en": "Uffe fiddles."}
    },
    {
      "id": "first",
      "date": "2000-03-01",
      "sources": [{"name": "Testbladet", "url": "https://example.com/first"}],
      "title": {"sv": "Första nyheten"},
      "body": {"sv": "Något hände."}
    }
  ]
}
''';

void main() {
  test('parses events from json and sorts them by date', () {
    final catalog = EventCatalog.fromJsonString(_catalogJson);
    expect(catalog.events.map((event) => event.id), ['first', 'second']);
    final event = catalog.events.last;
    expect(event.date, DateTime.utc(2001, 6));
    expect(event.source, 'Dagens Arena');
    expect(event.url, 'https://example.com/second');
    expect(event.sources, hasLength(2));
    expect(event.sources.last.name, 'Wikipedia');
    expect(event.title(AppLanguage.sv), 'Svart städhjälp');
    expect(event.title(AppLanguage.en), 'Undeclared cleaning help');
  });

  test('falls back to Swedish when a translation is missing', () {
    final catalog = EventCatalog.fromJsonString(_catalogJson);
    final event = catalog.events.first;
    expect(event.title(AppLanguage.en), 'Första nyheten');
    expect(event.body(AppLanguage.en), 'Något hände.');
  });

  test('upTo returns only events that have happened', () {
    final catalog = EventCatalog.fromJsonString(_catalogJson);
    expect(catalog.upTo(DateTime.utc(2000, 2)), isEmpty);
    expect(
      catalog.upTo(DateTime.utc(2000, 3)).map((event) => event.id),
      ['first'],
    );
    expect(
      catalog.upTo(DateTime.utc(2002)).map((event) => event.id),
      ['first', 'second'],
    );
  });
}
