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
import 'package:fifflar_uffe/routes/pause_route.dart';
import 'package:fifflar_uffe/routes/skill_tree_route.dart';
import 'package:fifflar_uffe/services/i18n.dart';
import 'package:fifflar_uffe/services/persistence_service.dart';
import 'package:fifflar_uffe/ui/hud/date_counter.dart';
import 'package:fifflar_uffe/ui/hud/event_feed_component.dart';
import 'package:fifflar_uffe/ui/hud/hud_icon_button.dart';
import 'package:fifflar_uffe/ui/hud/sek_counter.dart';
import 'package:fifflar_uffe/ui/hud/shop_hint_component.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Route;

class FifflarUffeGame extends FlameGame<PlayWorld> {
  FifflarUffeGame() : super(world: PlayWorld());

  late final Economy economy;
  late final Timeline timeline;
  late final EventCatalog eventCatalog;
  late final I18n i18n;
  late final PersistenceService persistence;
  late final RouterComponent router;
  late final UffeComponent uffe;
  late final EventFeedComponent eventFeed;
  late final ShopHintComponent shopHint;

  static const double _maxDeltaTime = 5;

  double highScore = 0;
  bool _dirty = false;
  bool _gameOver = false;
  bool _capitalismBroken = false;

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
    i18n = I18n(initialLanguage: save.language);
    economy.addListener(() => _dirty = true);
    timeline.addListener(() => _dirty = true);
    i18n.language.addListener(
      () => persistence.saveLanguage(i18n.language.value),
    );

    camera.viewfinder
      ..anchor = Anchor.topLeft
      ..position = Vector2.zero();

    router = RouterComponent(
      initialRoute: 'home',
      routes: {
        'home': Route(Component.new, transparent: true),
        'pause': PauseRoute(),
        'about': AboutRoute(),
        'shop': SkillTreeRoute(),
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
    economy.reset();
    eventFeed.resetRun();
    shopHint.resetRun();
    timeline.reset();
    world.resetRun();
    saveNow();
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
    );
  }

  void _autosave() {
    if (_dirty) {
      saveNow();
    }
  }
}
