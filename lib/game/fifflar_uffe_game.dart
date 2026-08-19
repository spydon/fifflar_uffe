import 'package:fifflar_uffe/components/uffe_component.dart';
import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/play_world.dart';
import 'package:fifflar_uffe/model/economy.dart';
import 'package:fifflar_uffe/model/shop_item.dart';
import 'package:fifflar_uffe/model/timeline.dart';
import 'package:fifflar_uffe/routes/about_route.dart';
import 'package:fifflar_uffe/routes/game_over_route.dart';
import 'package:fifflar_uffe/routes/pause_route.dart';
import 'package:fifflar_uffe/routes/settings_route.dart';
import 'package:fifflar_uffe/routes/shop_route.dart';
import 'package:fifflar_uffe/services/i18n.dart';
import 'package:fifflar_uffe/services/persistence_service.dart';
import 'package:fifflar_uffe/ui/hud/date_counter.dart';
import 'package:fifflar_uffe/ui/hud/hud_icon_button.dart';
import 'package:fifflar_uffe/ui/hud/sek_counter.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' hide Route;

class FifflarUffeGame extends FlameGame<PlayWorld> {
  FifflarUffeGame() : super(world: PlayWorld());

  late final Economy economy;
  late final Timeline timeline;
  late final I18n i18n;
  late final PersistenceService persistence;
  late final RouterComponent router;
  late final UffeComponent uffe;

  double highScore = 0;
  bool _dirty = false;
  bool _gameOver = false;

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
    timeline = Timeline(elapsedDays: save.elapsedDays);
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
        'settings': SettingsRoute(),
        'about': AboutRoute(),
        'shop': ShopRoute(),
        'gameOver': GameOverRoute(),
      },
    );
    camera.viewport.addAll([
      SekCounter(),
      DateCounter(),
      HudIconButton(
        iconPath: AssetPaths.iconPause,
        margin: const EdgeInsets.only(bottom: 100, right: 16),
        onPressed: () => router.pushNamed('pause'),
      ),
      HudIconButton(
        iconPath: AssetPaths.iconStorefront,
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        onPressed: () => router.pushNamed('shop'),
      ),
      router,
      uffe = UffeComponent(priority: router.priority),
    ]);

    add(TimerComponent(period: 5, repeat: true, onTick: _autosave));
  }

  bool buyItem(ShopItemDef item) {
    final bought = economy.buy(item);
    if (bought) {
      uffe.say(item.quip(i18n.strings));
      saveNow();
    }
    return bought;
  }

  void handleGameOver() {
    if (_gameOver) {
      return;
    }
    _gameOver = true;
    if (economy.totalEarned > highScore) {
      highScore = economy.totalEarned;
    }
    saveNow();
    router.pushNamed('gameOver');
  }

  void restartRun() {
    _gameOver = false;
    economy.reset();
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
      owned: economy.owned,
    );
  }

  void _autosave() {
    if (_dirty) {
      saveNow();
    }
  }
}
