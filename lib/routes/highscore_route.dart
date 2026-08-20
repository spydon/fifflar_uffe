import 'dart:async';

import 'package:fifflar_uffe/services/highscore_client.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_close_button.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

class HighscoreRoute extends Route {
  HighscoreRoute()
    : super(HighscorePage.new, transparent: true, maintainState: false);
}

class HighscorePage extends ModalPage {
  HighscorePage() : super(designSize: Vector2(560, 640));

  static const int rowCount = 10;
  static const double _headerY = 72;
  static const double _firstRowY = 106;
  static const double _rowHeight = 36;
  static const double _dividerY = 478;
  static const double _footerY = 494;
  static const double _secondFooterY = 530;
  static const double _messageY = 270;

  final List<TextComponent> _ranks = [];
  final List<TextComponent> _names = [];
  final List<TextComponent> _scores = [];
  late final TextComponent _rankHeader;
  late final TextComponent _nameHeader;
  late final TextComponent _scoreHeader;
  late final TextComponent _message;
  late final TextComponent _myBest;
  late final TextComponent _brokenCount;
  late final GameButton _retry;
  late final RectangleComponent _divider;

  Leaderboard? _leaderboard;
  bool _built = false;
  bool _loading = false;
  bool _failed = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (isNarrowScreen) {
      resizePanel(Vector2(460, designSize.y));
    }
    final center = designSize.x / 2;
    final left = isNarrowScreen ? 36.0 : 52.0;
    final right = designSize.x - left;
    final rankX = left + 32;
    final nameX = left + 48;
    panel.addAll([
      PanelComponent(size: designSize.clone()),
      PanelHeader(
        title: (strings) => strings.highscores,
        size: Vector2(360, 68),
        position: Vector2(center, 0),
        anchor: Anchor.center,
      ),
      PanelCloseButton(
        position: Vector2(designSize.x - 16, 16),
        anchor: Anchor.center,
        onPressed: close,
      ),
      for (var i = 0; i < rowCount; i++) ...[
        _ranks.addAndReturn(
          TextComponent(
            textRenderer: TextStyles.statValue,
            anchor: Anchor.topRight,
            position: Vector2(rankX, _firstRowY + i * _rowHeight),
          ),
        ),
        _names.addAndReturn(
          TextComponent(
            textRenderer: TextStyles.statValue,
            anchor: Anchor.topLeft,
            position: Vector2(nameX, _firstRowY + i * _rowHeight),
          ),
        ),
        _scores.addAndReturn(
          TextComponent(
            textRenderer: TextStyles.statValue,
            anchor: Anchor.topRight,
            position: Vector2(right, _firstRowY + i * _rowHeight),
          ),
        ),
      ],
      _myBest = TextComponent(
        textRenderer: TextStyles.statLabel,
        anchor: Anchor.topCenter,
        position: Vector2(center, _footerY),
      ),
      _brokenCount = TextComponent(
        textRenderer: TextStyles.statLabel,
        anchor: Anchor.topCenter,
        position: Vector2(center, _secondFooterY),
      ),
      _message = TextComponent(
        textRenderer: TextStyles.info,
        anchor: Anchor.center,
        position: Vector2(center, _messageY),
      ),
    ]);
    _rankHeader = TextComponent(
      text: '#',
      textRenderer: TextStyles.statLabel,
      anchor: Anchor.topRight,
      position: Vector2(rankX, _headerY),
    );
    _nameHeader = TextComponent(
      textRenderer: TextStyles.statLabel,
      anchor: Anchor.topLeft,
      position: Vector2(nameX, _headerY),
    );
    _scoreHeader = TextComponent(
      textRenderer: TextStyles.statLabel,
      anchor: Anchor.topRight,
      position: Vector2(right, _headerY),
    );
    _divider = RectangleComponent(
      size: Vector2(designSize.x - 2 * left, 2),
      position: Vector2(left, _dividerY),
      paint: Paint()..color = const Color(0x668A7156),
    );
    _retry = GameButton(
      label: (strings) => strings.retry,
      color: GameButtonColor.blue,
      size: Vector2(210, 84),
      position: Vector2(center, _messageY + 80),
      anchor: Anchor.center,
      onPressed: () => unawaited(_load()),
    );
    _leaderboard = game.highscore.lastLeaderboard;
    _built = true;
    unawaited(_load());
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

  Future<void> _load() async {
    if (_loading) {
      return;
    }
    _loading = true;
    _failed = false;
    _refresh();
    try {
      _leaderboard = await game.highscore.fetchLeaderboard();
    } on HighscoreException {
      _failed = true;
    } on TimeoutException {
      _failed = true;
    } finally {
      _loading = false;
      if (isMounted) {
        _refresh();
      }
    }
  }

  void _refresh() {
    if (!_built) {
      return;
    }
    final strings = game.i18n.strings;
    final leaderboard = _leaderboard;
    _nameHeader.text = strings.highscoreNameHeader;
    _scoreHeader.text = strings.highscoreScoreHeader;
    final showTable = leaderboard != null;
    final showRetry = _failed && leaderboard == null;
    _setVisible(_retry, showRetry);
    if (leaderboard == null) {
      _message.text = _failed ? strings.highscoreLoadError : strings.loading;
    } else if (leaderboard.top.isEmpty) {
      _message.text = strings.emptyLeaderboard;
    } else {
      _message.text = '';
    }
    _setVisible(_rankHeader, showTable);
    _setVisible(_nameHeader, showTable);
    _setVisible(_scoreHeader, showTable);
    _setVisible(_divider, showTable);
    for (var i = 0; i < rowCount; i++) {
      final entry = leaderboard != null && i < leaderboard.top.length
          ? leaderboard.top[i]
          : null;
      final style = entry?.isMe ?? false
          ? TextStyles.statValueHighlight
          : TextStyles.statValue;
      _ranks[i]
        ..text = entry == null ? '' : '${entry.rank}.'
        ..textRenderer = style;
      _names[i]
        ..text = entry?.name ?? ''
        ..textRenderer = style;
      _scores[i]
        ..text = entry == null ? '' : formatSekShort(entry.score)
        ..textRenderer = style;
    }
    if (leaderboard == null) {
      _myBest.text = '';
      _brokenCount.text = '';
      return;
    }
    final me = leaderboard.me;
    _myBest.text = me == null
        ? strings.notRanked
        : strings.yourBest(formatSekShort(me.score), me.rank);
    _brokenCount.text = strings.brokenCapitalismCount(
      leaderboard.brokenCapitalismCount,
    );
  }

  void _setVisible(Component component, bool visible) {
    if (visible && component.parent == null) {
      panel.add(component);
    } else if (!visible && component.parent != null) {
      component.removeFromParent();
    }
  }
}

extension on List<TextComponent> {
  TextComponent addAndReturn(TextComponent component) {
    add(component);
    return component;
  }
}
