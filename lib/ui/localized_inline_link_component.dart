import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/strings.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:url_launcher/url_launcher.dart';

/// A centered, word wrapped sentence where the part written inside square
/// brackets in the localized string is rendered as a tappable link.
class LocalizedInlineLinkComponent extends PositionComponent
    with HasGameReference<FifflarUffeGame> {
  LocalizedInlineLinkComponent({
    required this.selector,
    required this.url,
    required this.textRenderer,
    required this.linkRenderer,
    required double maxWidth,
    super.position,
    super.anchor,
    super.priority,
  }) : super(size: Vector2(maxWidth, 0));

  static const double _lineGap = 2;
  static final RegExp _linkPattern = RegExp(r'\[([^\]]+)\]');

  final String Function(Strings strings) selector;
  final String url;
  final TextPaint textRenderer;
  final TextPaint linkRenderer;

  Iterable<String> get linkWords =>
      children.whereType<InlineLinkWord>().map((word) => word.text);

  String get text => children
      .map(
        (word) => switch (word) {
          InlineLinkWord() => word.text,
          TextComponent() => word.text,
          _ => '',
        },
      )
      .join(' ');

  @override
  void onMount() {
    super.onMount();
    _rebuild();
    game.i18n.language.addListener(_rebuild);
  }

  @override
  void onRemove() {
    game.i18n.language.removeListener(_rebuild);
    super.onRemove();
  }

  void _rebuild() {
    for (final child in children.toList()) {
      child.removeFromParent();
    }
    final words = _words(selector(game.i18n.strings));
    final lines = <List<PositionComponent>>[[]];
    final spaceWidth =
        textRenderer.getLineMetrics('a b').width -
        textRenderer.getLineMetrics('ab').width;
    var lineWidth = 0.0;
    for (final word in words) {
      final needed = lineWidth == 0
          ? word.size.x
          : lineWidth + spaceWidth + word.size.x;
      if (lineWidth > 0 && needed > size.x) {
        lines.add([]);
        lineWidth = word.size.x;
      } else {
        lineWidth = needed;
      }
      lines.last.add(word);
    }
    var y = 0.0;
    for (final line in lines) {
      final width =
          line.fold(0.0, (sum, word) => sum + word.size.x) +
          spaceWidth * (line.length - 1);
      final height = line.fold(
        0.0,
        (max, word) => word.size.y > max ? word.size.y : max,
      );
      var x = (size.x - width) / 2;
      for (final word in line) {
        word.position = Vector2(x, y + (height - word.size.y) / 2);
        x += word.size.x + spaceWidth;
      }
      y += height + _lineGap;
    }
    addAll(lines.expand((line) => line));
    size.setValues(size.x, lines.isEmpty ? 0 : y - _lineGap);
  }

  List<PositionComponent> _words(String text) {
    final words = <PositionComponent>[];
    var cursor = 0;
    void addPlain(String segment) {
      for (final word in segment.split(' ')) {
        if (word.isNotEmpty) {
          words.add(TextComponent(text: word, textRenderer: textRenderer));
        }
      }
    }

    for (final match in _linkPattern.allMatches(text)) {
      addPlain(text.substring(cursor, match.start));
      for (final word in match.group(1)!.split(' ')) {
        if (word.isNotEmpty) {
          words.add(
            InlineLinkWord(text: word, textRenderer: linkRenderer, url: url),
          );
        }
      }
      cursor = match.end;
    }
    addPlain(text.substring(cursor));
    return words;
  }
}

class InlineLinkWord extends PositionComponent with TapCallbacks {
  InlineLinkWord({
    required this.text,
    required TextPaint textRenderer,
    required this.url,
  }) {
    final label = TextComponent(text: text, textRenderer: textRenderer);
    size.setFrom(label.size);
    add(label);
  }

  final String text;
  final String url;

  @override
  bool containsLocalPoint(Vector2 point) {
    const slack = 10.0;
    return point.x >= -slack &&
        point.x <= size.x + slack &&
        point.y >= -slack &&
        point.y <= size.y + slack;
  }

  @override
  void onTapUp(TapUpEvent event) {
    launchUrl(Uri.base.resolve(url));
  }
}
