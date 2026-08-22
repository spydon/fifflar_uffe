import 'dart:async';

import 'package:fifflar_uffe/services/highscore_client.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_close_button.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:fifflar_uffe/ui/table_grid_component.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class HighscoreRoute extends Route {
  HighscoreRoute()
    : super(HighscorePage.new, transparent: true, maintainState: false);
}

class HighscorePage extends ModalPage {
  HighscorePage() : super(designSize: Vector2(560, 700));

  static const int rowCount = 10;
  static const double _tabsY = 98;
  static const double _tableTop = 138;
  static const double _headerHeight = 36;
  static const double _rowHeight = 34;
  static const double _cellPadding = 10;
  static const double _footerGap = 22;
  static const double _footerSpacing = 28;
  static const double _bottomPadding = 58;
  static const double _messageY = 330;

  final List<TextComponent> _ranks = [];
  final List<TextComponent> _names = [];
  final List<TextComponent> _scores = [];
  late final TableGridComponent _grid;
  late final TextComponent _rankHeader;
  late final TextComponent _nameHeader;
  late final TextComponent _scoreHeader;
  late final TextComponent _message;
  late final TextComponent _myBest;
  late final TextComponent _brokenCount;
  late final TextComponent _gamesPlayed;
  late final GameButton _retry;
  final List<GameButton> _tabs = [];

  Leaderboard? _leaderboard;
  LeaderboardPeriod _period = LeaderboardPeriod.allTime;
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
    final narrow = isNarrowScreen;
    final left = narrow ? 28.0 : 40.0;
    final tableWidth = designSize.x - 2 * left;
    final columnWidths = narrow
        ? [44.0, 140.0, tableWidth - 184]
        : [48.0, 190.0, tableWidth - 238];
    _grid = TableGridComponent(
      columnWidths: columnWidths,
      headerHeight: _headerHeight,
      rowHeight: _rowHeight,
      rowCount: rowCount,
      position: Vector2(left, _tableTop),
    );
    Vector2 cell(int column, double top, double height) => Vector2(
      left + _grid.columnLeft(column) + _cellPadding,
      _tableTop + top + height / 2,
    );
    final footerTop = _tableTop + _grid.size.y + _footerGap;
    resizePanel(
      Vector2(designSize.x, footerTop + 2 * _footerSpacing + _bottomPadding),
    );
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
            anchor: Anchor.centerLeft,
            position: cell(0, _grid.rowTop(i), _rowHeight),
          ),
        ),
        _names.addAndReturn(
          TextComponent(
            textRenderer: TextStyles.statValue,
            anchor: Anchor.centerLeft,
            position: cell(1, _grid.rowTop(i), _rowHeight),
          ),
        ),
        _scores.addAndReturn(
          TextComponent(
            textRenderer: TextStyles.statValue,
            anchor: Anchor.centerLeft,
            position: cell(2, _grid.rowTop(i), _rowHeight),
          ),
        ),
      ],
      _myBest = TextComponent(
        textRenderer: TextStyles.statLabel,
        anchor: Anchor.topCenter,
        position: Vector2(center, footerTop),
      ),
      _brokenCount = TextComponent(
        textRenderer: TextStyles.statLabel,
        anchor: Anchor.topCenter,
        position: Vector2(center, footerTop + _footerSpacing),
      ),
      _gamesPlayed = TextComponent(
        textRenderer: TextStyles.statLabel,
        anchor: Anchor.topCenter,
        position: Vector2(center, footerTop + 2 * _footerSpacing),
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
      anchor: Anchor.centerLeft,
      position: cell(0, 0, _headerHeight),
    );
    _nameHeader = TextComponent(
      textRenderer: TextStyles.statLabel,
      anchor: Anchor.centerLeft,
      position: cell(1, 0, _headerHeight),
    );
    _scoreHeader = TextComponent(
      textRenderer: TextStyles.statLabel,
      anchor: Anchor.centerLeft,
      position: cell(2, 0, _headerHeight),
    );
    _retry = GameButton(
      label: (strings) => strings.retry,
      color: GameButtonColor.blue,
      position: Vector2(center, _messageY + 80),
      anchor: Anchor.center,
      onPressed: () => unawaited(_load()),
    );
    _leaderboard = game.highscore.cachedLeaderboard(_period);
    _built = true;
    _buildTabs();
    unawaited(_load());
  }

  void _buildTabs() {
    for (final tab in _tabs) {
      tab.removeFromParent();
    }
    _tabs.clear();
    final narrow = isNarrowScreen;
    final center = designSize.x / 2;
    final spacing = narrow ? 138.0 : 160.0;
    final size = narrow ? Vector2(128, 50) : Vector2(150, 52);
    for (final (index, period) in LeaderboardPeriod.values.indexed) {
      final tab = GameButton(
        label: (strings) => switch (period) {
          LeaderboardPeriod.allTime => strings.periodAllTime,
          LeaderboardPeriod.weekly => strings.periodWeekly,
          LeaderboardPeriod.daily => strings.periodDaily,
        },
        color: period == _period ? GameButtonColor.green : GameButtonColor.blue,
        size: size,
        anchor: Anchor.center,
        position: Vector2(center + (index - 1) * spacing, _tabsY),
        onPressed: () => _selectPeriod(period),
      );
      _tabs.add(tab);
      panel.add(tab);
    }
  }

  void _selectPeriod(LeaderboardPeriod period) {
    if (period == _period) {
      return;
    }
    _period = period;
    _leaderboard = game.highscore.cachedLeaderboard(period);
    _failed = false;
    _buildTabs();
    _refresh();
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
    final period = _period;
    _loading = true;
    _failed = false;
    _refresh();
    try {
      final leaderboard = await game.highscore.fetchLeaderboard(
        period: period,
      );
      if (period == _period) {
        _leaderboard = leaderboard;
      }
    } on HighscoreException {
      _failed = period == _period;
    } on TimeoutException {
      _failed = period == _period;
    } finally {
      _loading = false;
      if (isMounted) {
        if (period != _period) {
          unawaited(_load());
        }
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
    final showTable = leaderboard != null && leaderboard.top.isNotEmpty;
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
    _setVisible(_grid, showTable);
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
      _gamesPlayed.text = '';
      return;
    }
    final me = leaderboard.me;
    _myBest.text = me == null
        ? strings.notRanked
        : strings.yourBest(formatSekShort(me.score), me.rank);
    _brokenCount.text = strings.brokenCapitalismCount(
      leaderboard.brokenCapitalismCount,
    );
    _gamesPlayed.text = strings.gamesPlayed(leaderboard.gamesPlayed);
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
