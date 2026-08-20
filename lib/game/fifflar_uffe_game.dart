import 'dart:async';

import 'package:fifflar_uffe/components/floating_text_component.dart';
import 'package:fifflar_uffe/components/uffe_component.dart';
import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/play_world.dart';
import 'package:fifflar_uffe/model/economy.dart';
import 'package:fifflar_uffe/model/game_event.dart';
import 'package:fifflar_uffe/model/skill_def.dart';
import 'package:fifflar_uffe/model/timeline.dart';
import 'package:fifflar_uffe/routes/about_route.dart';
import 'package:fifflar_uffe/routes/broken_capitalism_route.dart';
import 'package:fifflar_uffe/routes/game_over_route.dart';
import 'package:fifflar_uffe/routes/highscore_route.dart';
import 'package:fifflar_uffe/routes/main_menu_route.dart';
import 'package:fifflar_uffe/routes/pause_route.dart';
import 'package:fifflar_uffe/routes/settings_route.dart';
import 'package:fifflar_uffe/routes/skill_tree_route.dart';
import 'package:fifflar_uffe/services/highscore_client.dart';
import 'package:fifflar_uffe/services/highscore_service.dart';
import 'package:fifflar_uffe/services/i18n.dart';
import 'package:fifflar_uffe/services/persistence_service.dart';
import 'package:fifflar_uffe/ui/hud/date_counter.dart';
import 'package:fifflar_uffe/ui/hud/event_feed_component.dart';
import 'package:fifflar_uffe/ui/hud/hud_icon_button.dart';
import 'package:fifflar_uffe/ui/hud/sek_counter.dart';
import 'package:fifflar_uffe/ui/hud/shop_hint_component.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/snake_case.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Route;

class FifflarUffeGame extends FlameGame<PlayWorld> with KeyboardEvents {
  FifflarUffeGame({this.highscoreClient}) : super(world: PlayWorld());

  late final Economy economy;
  late final Timeline timeline;
  late final EventCatalog eventCatalog;
  late final I18n i18n;
  late final PersistenceService persistence;
  late final HighscoreService highscore;
  late final RouterComponent router;
  late final UffeComponent uffe;
  late final EventFeedComponent eventFeed;
  late final ShopHintComponent shopHint;

  static const double _maxDeltaTime = 5;
  static const double _progressReportPeriod = 30;
  static const double _freshRunMaxDays = 80;

  final HighscoreClient? highscoreClient;

  double highScore = 0;
  String? runId;
  int runSeq = 0;
  bool runFlagged = false;
  String? highscoreName;
  bool highscoreSubmitted = false;
  int? highscoreRank;
  bool capitalismReported = false;

  bool _dirty = false;
  bool _gameOver = false;
  bool _capitalismBroken = false;
  bool _reporting = false;
  double? _lastReportedDays;
  Future<void>? _runTokenRequest;

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) => KeyEventResult.ignored;

  @override
  void update(double dt) {
    if (dt > _maxDeltaTime) {
      return;
    }
    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    await images.loadAll(AssetPaths.all);
    persistence = await PersistenceService.create();
    final save = persistence.load();
    economy = Economy(
      balance: save.balance,
      totalEarned: save.totalEarned,
      owned: save.owned,
    );
    timeline = Timeline(
      elapsedDays: save.elapsedDays,
      unbounded: save.continued,
    );
    _gameOver = save.continued;
    eventCatalog = EventCatalog.fromJsonString(
      await rootBundle.loadString('assets/data/events.json'),
    );
    highScore = save.highScore;
    runId = save.runId;
    runSeq = save.runSeq;
    runFlagged = save.runFlagged;
    highscoreName = save.highscoreName;
    highscoreSubmitted = save.highscoreSubmitted;
    highscoreRank = save.highscoreRank;
    capitalismReported = save.capitalismReported;
    i18n = I18n(initialLanguage: save.language);
    highscore = HighscoreService(client: highscoreClient);
    economy.addListener(() => _dirty = true);
    timeline.addListener(() => _dirty = true);
    i18n.language.addListener(
      () => persistence.saveLanguage(i18n.language.value),
    );
    highscore.available.addListener(_onHighscoreAvailability);

    camera.viewfinder
      ..anchor = Anchor.topLeft
      ..position = Vector2.zero();

    router = RouterComponent(
      initialRoute: 'home',
      routes: {
        'home': Route(Component.new, transparent: true),
        'mainMenu': MainMenuRoute(),
        'pause': PauseRoute(),
        'settings': SettingsRoute(),
        'about': AboutRoute(),
        'shop': SkillTreeRoute(),
        'highscore': HighscoreRoute(),
        'gameOver': GameOverRoute(),
        'brokenCapitalism': BrokenCapitalismRoute(),
      },
    );
    camera.viewport.addAll([
      SekCounter(),
      DateCounter(),
      eventFeed = EventFeedComponent(),
      HudIconButton(
        iconPath: AssetPaths.iconGear,
        margin: const EdgeInsets.only(bottom: 100, right: 16),
        onPressed: () => router.pushNamed('pause'),
      ),
      HudIconButton(
        iconPath: AssetPaths.iconStorefront,
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        onPressed: () => router.pushNamed('shop'),
      ),
      shopHint = ShopHintComponent(),
      router,
      uffe = UffeComponent(),
    ]);

    add(TimerComponent(period: 5, repeat: true, onTick: _autosave));
    add(
      TimerComponent(
        period: _progressReportPeriod,
        repeat: true,
        onTick: () => unawaited(_reportProgress()),
      ),
    );
    unawaited(highscore.probe());
    if (!save.menuSeen) {
      unawaited(router.mounted.then((_) => router.pushNamed('mainMenu')));
    }
  }

  bool buyItem(SkillDef skill) {
    final bought = economy.buy(skill);
    if (bought) {
      uffe.say(skill.quip(i18n.strings));
      if (skill.isClickMultiplier) {
        camera.viewport.add(
          FloatingTextComponent(
            text: 'x${economy.clickMultiplier} ${i18n.strings.perClick}',
            position: Vector2(size.x / 2, size.y * 0.35),
            style: TextStyles.floatingStyle.copyWith(fontSize: 42),
            lifetime: 1.5,
            priority: router.priority + 2,
          ),
        );
      }
      saveNow();
    }
    return bought;
  }

  void handleGameOver() {
    if (_gameOver) {
      return;
    }
    _gameOver = true;
    _openEnding('gameOver');
  }

  void handleBalanceOverflow() {
    if (_capitalismBroken || !router.isMounted) {
      return;
    }
    _capitalismBroken = true;
    _openEnding('brokenCapitalism');
    unawaited(_reportBrokenCapitalism());
  }

  void _openEnding(String routeName) {
    if (economy.totalEarned > highScore) {
      highScore = economy.totalEarned;
    }
    saveNow();
    while (router.currentRoute != router.routes['home']) {
      router.pop();
    }
    router.pushNamed(routeName);
  }

  void continueRun() {
    timeline.continueBeyondEnd();
    saveNow();
  }

  void restartRun() {
    _gameOver = false;
    _capitalismBroken = false;
    runId = null;
    runSeq = 0;
    runFlagged = false;
    highscoreSubmitted = false;
    highscoreRank = null;
    capitalismReported = false;
    _lastReportedDays = null;
    economy.reset();
    eventFeed.resetRun();
    shopHint.resetRun();
    timeline.reset();
    world.resetRun();
    saveNow();
    if (highscore.available.value) {
      unawaited(ensureRunToken());
    }
  }

  bool get isFreshRun =>
      !timeline.unbounded && timeline.elapsedDays <= _freshRunMaxDays;

  bool get hasActiveRun =>
      highscore.available.value && runId != null && !runFlagged;

  bool get canSubmitHighscore =>
      hasActiveRun &&
      !highscoreSubmitted &&
      timeline.isOver &&
      !timeline.unbounded &&
      economy.totalEarned > 0 &&
      economy.totalEarned.isFinite;

  RunSnapshot get runSnapshot => RunSnapshot(
    seq: runSeq + 1,
    elapsedDays: timeline.elapsedDays,
    totalEarned: economy.totalEarned,
    balance: economy.balance,
    owned: economy.owned.map(
      (id, count) => MapEntry(id.snakeCaseName, count),
    ),
  );

  void _onHighscoreAvailability() {
    if (highscore.available.value && runId == null && isFreshRun) {
      unawaited(ensureRunToken());
    }
  }

  Future<void> ensureRunToken() {
    final pending = _runTokenRequest;
    if (pending != null) {
      return pending;
    }
    if (runId != null || !isFreshRun) {
      return Future.value();
    }
    final request = _requestRunToken().whenComplete(
      () => _runTokenRequest = null,
    );
    _runTokenRequest = request;
    return request;
  }

  Future<void> _requestRunToken() async {
    try {
      final token = await highscore.startRun();
      if (runId != null || !isFreshRun) {
        return;
      }
      runId = token.id;
      runSeq = token.seq;
      runFlagged = false;
      _lastReportedDays = null;
      saveNow();
    } on HighscoreException {
      return;
    } on TimeoutException {
      return;
    }
  }

  Future<void> _reportProgress() async {
    final id = runId;
    if (id == null ||
        _reporting ||
        !hasActiveRun ||
        world.updatePaused ||
        timeline.unbounded ||
        timeline.isOver) {
      return;
    }
    final snapshot = runSnapshot;
    if (snapshot.elapsedDays == _lastReportedDays) {
      return;
    }
    _reporting = true;
    try {
      final seq = await highscore.reportProgress(
        runId: id,
        snapshot: snapshot,
      );
      if (runId == id) {
        runSeq = seq;
        _lastReportedDays = snapshot.elapsedDays;
        saveNow();
      }
    } on HighscoreException catch (exception) {
      if (runId == id) {
        await _handleRunError(id, exception);
      }
    } on TimeoutException {
      return;
    } finally {
      _reporting = false;
    }
  }

  Future<SubmitResult> submitHighscore(String name) async {
    final id = runId;
    if (id == null) {
      throw const HighscoreException(HighscoreError.unknownRun);
    }
    try {
      final result = await _withResync(
        id,
        () => highscore.submitScore(
          runId: id,
          name: name,
          snapshot: runSnapshot,
        ),
      );
      if (runId == id) {
        runSeq = result.seq;
        highscoreName = name;
        highscoreSubmitted = true;
        highscoreRank = result.rank;
        saveNow();
      }
      return result;
    } on HighscoreException catch (exception) {
      if (runId == id) {
        if (exception.error == HighscoreError.alreadySubmitted) {
          highscoreSubmitted = true;
          saveNow();
        } else {
          await _handleRunError(id, exception);
        }
      }
      rethrow;
    }
  }

  Future<void> _reportBrokenCapitalism() async {
    final id = runId;
    if (id == null || capitalismReported || !hasActiveRun) {
      return;
    }
    try {
      final seq = await _withResync(
        id,
        () => highscore.reportBrokenCapitalism(
          runId: id,
          snapshot: runSnapshot,
        ),
      );
      if (runId == id) {
        runSeq = seq;
        capitalismReported = true;
        saveNow();
      }
    } on HighscoreException catch (exception) {
      if (runId == id) {
        if (exception.error == HighscoreError.alreadySubmitted) {
          capitalismReported = true;
          saveNow();
        } else {
          await _handleRunError(id, exception);
        }
      }
    } on TimeoutException {
      return;
    }
  }

  Future<T> _withResync<T>(String id, Future<T> Function() call) async {
    try {
      return await call();
    } on HighscoreException catch (exception) {
      if (exception.error != HighscoreError.badSequence) {
        rethrow;
      }
      await _resync(id);
      if (runFlagged) {
        throw const HighscoreException(HighscoreError.flagged);
      }
      return call();
    }
  }

  Future<void> _handleRunError(String id, HighscoreException exception) async {
    if (exception.error == HighscoreError.badSequence) {
      await _resync(id);
    } else if (exception.error.flagsRun) {
      runFlagged = true;
      saveNow();
    }
  }

  Future<void> _resync(String id) async {
    try {
      final state = await highscore.runState(runId: id);
      if (runId != id) {
        return;
      }
      runSeq = state.seq;
      if (state.flagged != null) {
        runFlagged = true;
      }
      saveNow();
    } on HighscoreException {
      return;
    } on TimeoutException {
      return;
    }
  }

  void saveNow() {
    _dirty = false;
    persistence.saveGame(
      balance: economy.balance,
      totalEarned: economy.totalEarned,
      elapsedDays: timeline.elapsedDays,
      highScore: highScore,
      continued: timeline.unbounded,
      owned: economy.owned,
      runId: runId,
      runSeq: runSeq,
      runFlagged: runFlagged,
      highscoreName: highscoreName,
      highscoreSubmitted: highscoreSubmitted,
      highscoreRank: highscoreRank,
      capitalismReported: capitalismReported,
    );
  }

  void _autosave() {
    if (_dirty) {
      saveNow();
    }
  }
}
