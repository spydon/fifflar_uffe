import 'dart:convert';

import 'package:fifflar_uffe/components/building_component.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:fifflar_uffe/model/skill_id.dart';
import 'package:fifflar_uffe/model/timeline.dart';
import 'package:fifflar_uffe/routes/main_menu_route.dart';
import 'package:fifflar_uffe/routes/pause_route.dart';
import 'package:fifflar_uffe/routes/skill_detail_route.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/hud/event_card_component.dart';
import 'package:fifflar_uffe/ui/hud/event_feed_component.dart';
import 'package:fifflar_uffe/ui/hud/shop_hint_component.dart';
import 'package:fifflar_uffe/ui/hud/speed_boost_button.dart';
import 'package:fifflar_uffe/ui/language_flag_button.dart';
import 'package:fifflar_uffe/ui/switch_button.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/start_run.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWithGame<FifflarUffeGame>(
    'an ongoing game loads with the home route active',
    () {
      SharedPreferences.setMockInitialValues({
        'fifflar_uffe.save.v1': jsonEncode({
          'balance': 5.0,
          'elapsedDays': 100.0,
          'savedAt': '2026-08-19T00:00:00.000',
        }),
      });
      return FifflarUffeGame();
    },
    (game) async {
      game.update(0);
      await game.ready();
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['home']);
      expect(game.world.updatePaused, isFalse);
    },
  );

  testWithGame<FifflarUffeGame>(
    'a fresh run opens the main menu and freezes the world',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['mainMenu']);
      expect(game.world.updatePaused, isTrue);
      final page = game.router.currentRoute.children
          .whereType<MainMenuPage>()
          .single;
      final labels = page.panel.children
          .whereType<GameButton>()
          .map((button) => button.label(game.i18n.strings))
          .toList();
      expect(labels, ['Börja fiffla', 'Inställningar', 'Om']);
    },
  );

  testWithGame<FifflarUffeGame>(
    'starting from the main menu resumes the game',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      game.update(0);
      await game.ready();
      final page = game.router.currentRoute.children
          .whereType<MainMenuPage>()
          .single;
      page.panel.children
          .whereType<GameButton>()
          .firstWhere(
            (button) => button.label(game.i18n.strings) == 'Börja fiffla',
          )
          .onPressed!();
      game.update(1);
      await game.ready();
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['home']);
      expect(game.world.updatePaused, isFalse);
    },
  );

  testWithGame<FifflarUffeGame>(
    'the main menu opens the settings and about pages',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      game.update(0);
      await game.ready();
      final page = game.router.currentRoute.children
          .whereType<MainMenuPage>()
          .single;
      GameButton buttonLabelled(String label) =>
          page.panel.children.whereType<GameButton>().firstWhere(
            (button) => button.label(game.i18n.strings) == label,
          );
      buttonLabelled('Inställningar').onPressed!();
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['settings']);
      game.router.pop();
      game.update(0);
      await game.ready();
      buttonLabelled('Om').onPressed!();
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['about']);
      game.router.pop();
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['mainMenu']);
      expect(game.world.updatePaused, isTrue);
    },
  );

  testWithGame<FifflarUffeGame>(
    'frame deltas above five seconds are discarded',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      final before = game.timeline.elapsedDays;
      game.update(6);
      expect(game.timeline.elapsedDays, before);
      game.update(1);
      expect(game.timeline.elapsedDays, greaterThan(before));
    },
  );

  testWithGame<FifflarUffeGame>(
    'a building appears after the first purchase of an item',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      expect(game.world.children.whereType<BuildingComponent>(), isEmpty);
      final item = skillCatalog.first;
      for (var i = 0; i < item.basePrice; i++) {
        game.economy.earnClick();
      }
      expect(game.buyItem(item), isTrue);
      game.update(0);
      await game.ready();
      final buildings = game.world.children.whereType<BuildingComponent>();
      expect(buildings.map((building) => building.skill.id), [item.id]);
    },
  );

  testWithGame<FifflarUffeGame>(
    'buildings from a saved game appear on load',
    () {
      SharedPreferences.setMockInitialValues({
        'fifflar_uffe.save.v1': jsonEncode({
          'balance': 500.0,
          'owned': {'lower_taxes': 2},
          'savedAt': '2026-08-19T00:00:00.000',
        }),
      });
      return FifflarUffeGame();
    },
    (game) async {
      game.update(0);
      await game.ready();
      final buildings = game.world.children.whereType<BuildingComponent>();
      expect(buildings.map((building) => building.skill.id), [
        SkillId.lowerTaxes,
      ]);
    },
  );

  testWithGame<FifflarUffeGame>(
    'reaching election day ends the game and restart begins a new run',
    () {
      SharedPreferences.setMockInitialValues({
        'fifflar_uffe.save.v1': jsonEncode({
          'balance': 10.0,
          'totalEarned': 25.0,
          'elapsedDays': Timeline.totalDays - 0.5,
          'owned': {'lower_taxes': 1},
          'savedAt': '2026-08-19T00:00:00.000',
        }),
      });
      return FifflarUffeGame();
    },
    (game) async {
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['home']);
      game.update(1);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['gameOver']);
      expect(game.world.updatePaused, isTrue);
      expect(game.timeline.isOver, isTrue);
      expect(game.highScore, 25.0);
      game.restartRun();
      game.router.pop();
      game.update(0);
      await game.ready();
      expect(game.world.updatePaused, isFalse);
      expect(game.economy.balance, 0);
      expect(game.economy.totalEarned, 0);
      expect(game.economy.owned, isEmpty);
      expect(game.timeline.elapsedDays, 0);
      expect(game.world.children.whereType<BuildingComponent>(), isEmpty);
      expect(game.highScore, 25.0);
    },
  );

  testWithGame<FifflarUffeGame>(
    'the skill tree and its detail pages pause the world',
    FifflarUffeGame.new,
    (game) async {
      await startRun(game);
      final before = game.timeline.elapsedDays;
      game.router.pushNamed('shop');
      game.update(0);
      await game.ready();
      expect(game.world.updatePaused, isTrue);
      game.router.pushRoute(SkillDetailRoute(skill: skillCatalog.first));
      game.update(0);
      await game.ready();
      expect(game.world.updatePaused, isTrue);
      game.router.pop();
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['shop']);
      expect(game.world.updatePaused, isTrue);
      game.update(1);
      expect(game.timeline.elapsedDays, before);
      game.router.pop();
      game.update(0);
      await game.ready();
      expect(game.world.updatePaused, isFalse);
    },
  );

  testWithGame<FifflarUffeGame>(
    'open popups are closed when the game over banner appears',
    () {
      SharedPreferences.setMockInitialValues({
        'fifflar_uffe.save.v1': jsonEncode({
          'balance': 10.0,
          'totalEarned': 25.0,
          'elapsedDays': Timeline.totalDays - 0.5,
          'owned': <String, int>{},
          'savedAt': '2026-08-19T00:00:00.000',
        }),
      });
      return FifflarUffeGame();
    },
    (game) async {
      game.update(0);
      await game.ready();
      game.router.pushNamed('about');
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['about']);
      game.update(1);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['gameOver']);
      game.router.pop();
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['home']);
    },
  );

  testWithGame<FifflarUffeGame>(
    'continuing after game over keeps the run going past election day',
    () {
      SharedPreferences.setMockInitialValues({
        'fifflar_uffe.save.v1': jsonEncode({
          'balance': 10.0,
          'totalEarned': 25.0,
          'elapsedDays': Timeline.totalDays - 0.5,
          'owned': {'lower_taxes': 1},
          'savedAt': '2026-08-19T00:00:00.000',
        }),
      });
      return FifflarUffeGame();
    },
    (game) async {
      game.update(0);
      await game.ready();
      game.update(1);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['gameOver']);
      game.continueRun();
      game.router.pop();
      game.update(0);
      await game.ready();
      expect(game.world.updatePaused, isFalse);
      game.update(5);
      await game.ready();
      expect(game.timeline.elapsedDays, greaterThan(Timeline.totalDays + 5));
      expect(game.router.currentRoute, game.router.routes['home']);
      expect(game.economy.owned, {SkillId.lowerTaxes: 1});
      expect(game.persistence.load().continued, isTrue);
    },
  );

  testWithGame<FifflarUffeGame>(
    'a continued save loads past election day without a game over',
    () {
      SharedPreferences.setMockInitialValues({
        'fifflar_uffe.save.v1': jsonEncode({
          'balance': 10.0,
          'totalEarned': 25.0,
          'elapsedDays': Timeline.totalDays + 50.0,
          'highScore': 25.0,
          'continued': true,
          'owned': <String, int>{},
          'savedAt': '2026-08-19T00:00:00.000',
        }),
      });
      return FifflarUffeGame();
    },
    (game) async {
      game.update(0);
      await game.ready();
      game.update(1);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['home']);
      expect(game.world.updatePaused, isFalse);
      expect(game.timeline.elapsedDays, greaterThan(Timeline.totalDays + 50));
    },
  );

  testWithGame<FifflarUffeGame>(
    'buildings sit in the same branch and tier layout as the shop',
    () {
      SharedPreferences.setMockInitialValues({
        'fifflar_uffe.save.v1': jsonEncode({
          'balance': 0.0,
          'owned': {'hire_cleaner': 1, 'write_book': 1, 'privatize_schools': 1},
          'savedAt': '2026-08-19T00:00:00.000',
        }),
      });
      return FifflarUffeGame();
    },
    (game) async {
      game.update(0);
      await game.ready();
      game.update(1);
      await game.ready();
      final buildings = {
        for (final building
            in game.world.children.whereType<BuildingComponent>())
          building.skill.id: building,
      };
      final cleaner = buildings[SkillId.hireCleaner]!;
      final book = buildings[SkillId.writeBook]!;
      final schools = buildings[SkillId.privatizeSchools]!;
      expect(book.position.x, cleaner.position.x);
      expect(book.position.y, greaterThan(cleaner.position.y));
      expect(schools.position.y, book.position.y);
      expect(schools.position.x, greaterThan(book.position.x));
      final factor = BuildingComponent.layoutFactor(game.size);
      expect(
        schools.position.x - book.position.x,
        closeTo((104 + 24) * factor, 0.01),
      );
      expect(
        book.position.y - cleaner.position.y,
        closeTo((130 + 24) * factor, 0.01),
      );
    },
  );

  testWithGame<FifflarUffeGame>(
    'turning sound off in the settings is persisted',
    FifflarUffeGame.new,
    (game) async {
      await startRun(game);
      expect(game.soundEnabled.value, isTrue);
      game.router.pushNamed('settings');
      game.update(0);
      await game.ready();
      final toggle = game.router.currentRoute
          .descendants()
          .whereType<SwitchButton>()
          .single;
      toggle.value.value = !toggle.value.value;
      game.update(0);
      await game.ready();
      expect(game.soundEnabled.value, isFalse);
      expect(game.persistence.load().soundEnabled, isFalse);
    },
  );

  testWithGame<FifflarUffeGame>(
    'the speed boost button doubles the pace of the world and is persisted',
    FifflarUffeGame.new,
    (game) async {
      await startRun(game);
      final button = game.camera.viewport.children
          .whereType<SpeedBoostButton>()
          .single;
      final toggle = button.children.whereType<ToggleButtonComponent>().single;
      expect(button.isActive, isFalse);
      expect(game.world.timeScale, 1);
      final normalStart = game.timeline.elapsedDays;
      game.update(1);
      expect(
        game.timeline.elapsedDays - normalStart,
        closeTo(Timeline.daysPerSecond, 1e-9),
      );

      toggle.isSelected = true;
      game.update(0);
      await game.ready();
      expect(game.speedBoost.value, isTrue);
      expect(button.isActive, isTrue);
      expect(game.world.timeScale, FifflarUffeGame.boostedTimeScale);
      final boostedStart = game.timeline.elapsedDays;
      game.update(1);
      expect(
        game.timeline.elapsedDays - boostedStart,
        closeTo(2 * Timeline.daysPerSecond, 1e-9),
      );
      expect(game.persistence.load().speedBoost, isTrue);

      game.speedBoost.value = false;
      game.update(0);
      await game.ready();
      expect(button.isActive, isFalse);
      expect(game.world.timeScale, 1);
      expect(game.persistence.load().speedBoost, isFalse);
    },
  );

  testWithGame<FifflarUffeGame>(
    'a saved speed boost is active when the game loads',
    () {
      SharedPreferences.setMockInitialValues({
        'fifflar_uffe.speed_boost': true,
        'fifflar_uffe.save.v1': jsonEncode({
          'balance': 5.0,
          'elapsedDays': 100.0,
          'savedAt': '2026-08-19T00:00:00.000',
        }),
      });
      return FifflarUffeGame();
    },
    (game) async {
      game.update(0);
      await game.ready();
      game.update(0);
      await game.ready();
      expect(game.speedBoost.value, isTrue);
      expect(game.world.timeScale, FifflarUffeGame.boostedTimeScale);
      final button = game.camera.viewport.children
          .whereType<SpeedBoostButton>()
          .single;
      expect(button.isActive, isTrue);
    },
  );

  testWithGame<FifflarUffeGame>(
    'the pause menu opens the settings page',
    FifflarUffeGame.new,
    (game) async {
      await startRun(game);
      game.router.pushNamed('pause');
      game.update(0);
      await game.ready();
      final page = game.router.currentRoute.children
          .whereType<PausePage>()
          .single;
      expect(page.panel.children.whereType<LanguageFlagButton>(), isEmpty);
      final settings = page.panel.children.whereType<GameButton>().firstWhere(
        (button) =>
            button.label(game.i18n.strings) == game.i18n.strings.settings,
      );
      settings.onPressed!();
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['settings']);
    },
  );

  testWithGame<FifflarUffeGame>(
    'the shop hint stays on a narrow screen and in front of Uffe',
    FifflarUffeGame.new,
    (game) async {
      game.onGameResize(Vector2(360, 640));
      game.update(0);
      await game.ready();
      for (var i = 0; i < 10; i++) {
        game.economy.earnClick();
      }
      game.update(0);
      await game.ready();
      final hint = game.shopHint;
      expect(hint.isVisible, isTrue);
      expect(hint.scale.x, lessThan(1));
      expect(hint.position.x, greaterThanOrEqualTo(0));
      expect(hint.position.x + hint.scaledSize.x, lessThanOrEqualTo(360));
      expect(hint.priority, greaterThan(game.router.priority));
      expect(hint.priority, greaterThan(game.uffe.priority));
    },
  );

  testWithGame<FifflarUffeGame>(
    'an event card appears when its date is reached, not on load',
    () {
      SharedPreferences.setMockInitialValues({
        'fifflar_uffe.save.v1': jsonEncode({
          'balance': 0.0,
          'owned': <String, int>{},
          'elapsedDays': 516.0,
          'savedAt': '2026-08-19T00:00:00.000',
        }),
      });
      return FifflarUffeGame();
    },
    (game) async {
      game.update(0);
      await game.ready();
      Iterable<EventCardComponent> cards() =>
          game.eventFeed.children.whereType<EventCardComponent>();
      expect(cards(), isEmpty);
      game.update(1);
      await game.ready();
      expect(cards(), hasLength(1));
      expect(cards().single.event.id, 'svart_stadhjalp');
      game.restartRun();
      game.update(0);
      await game.ready();
      expect(cards(), isEmpty);
    },
  );

  testWithGame<FifflarUffeGame>(
    'events arriving together are queued so each can be read',
    () {
      SharedPreferences.setMockInitialValues({
        'fifflar_uffe.save.v1': jsonEncode({
          'balance': 0.0,
          'owned': <String, int>{},
          'elapsedDays': 516.0,
          'savedAt': '2026-08-19T00:00:00.000',
        }),
      });
      return FifflarUffeGame();
    },
    (game) async {
      game.update(0);
      await game.ready();
      Iterable<EventCardComponent> cards() =>
          game.eventFeed.children.whereType<EventCardComponent>();
      game.timeline.advance(60);
      game.update(0);
      await game.ready();
      expect(cards().single.event.id, 'svart_stadhjalp');
      expect(
        game.eventFeed.queuedEvents.map((event) => event.id),
        ['valstugereportaget'],
      );
      for (var i = 0; i < 5; i++) {
        game.update((EventFeedComponent.minReadTime - 0.5) / 5);
      }
      await game.ready();
      expect(cards().single.event.id, 'svart_stadhjalp');
      game.update(1);
      await game.ready();
      expect(cards().single.event.id, 'valstugereportaget');
      expect(game.eventFeed.queuedEvents, isEmpty);
    },
  );

  testWithGame<FifflarUffeGame>(
    'a dismissed card makes room for the next queued event at once',
    () {
      SharedPreferences.setMockInitialValues({
        'fifflar_uffe.save.v1': jsonEncode({
          'balance': 0.0,
          'owned': <String, int>{},
          'elapsedDays': 516.0,
          'savedAt': '2026-08-19T00:00:00.000',
        }),
      });
      return FifflarUffeGame();
    },
    (game) async {
      game.update(0);
      await game.ready();
      Iterable<EventCardComponent> cards() =>
          game.eventFeed.children.whereType<EventCardComponent>();
      game.timeline.advance(60);
      game.update(0);
      await game.ready();
      cards().single.removeFromParent();
      game.update(0);
      await game.ready();
      expect(cards().single.event.id, 'valstugereportaget');
    },
  );

  testWithGame<FifflarUffeGame>(
    'events already in the past are not replayed on load',
    () {
      SharedPreferences.setMockInitialValues({
        'fifflar_uffe.save.v1': jsonEncode({
          'balance': 0.0,
          'owned': <String, int>{},
          'elapsedDays': 600.0,
          'savedAt': '2026-08-19T00:00:00.000',
        }),
      });
      return FifflarUffeGame();
    },
    (game) async {
      game.update(0);
      await game.ready();
      game.update(1);
      await game.ready();
      expect(
        game.eventFeed.children.whereType<EventCardComponent>(),
        isEmpty,
      );
    },
  );

  testWithGame<FifflarUffeGame>(
    'the shop hint appears at ten kronor and fades after a few seconds',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      final hint = game.camera.viewport.children
          .whereType<ShopHintComponent>()
          .single;
      expect(hint.isVisible, isFalse);
      for (var i = 0; i < 10; i++) {
        game.economy.earnClick();
      }
      game.update(0.1);
      await game.ready();
      expect(hint.isVisible, isTrue);
      for (var i = 0; i < 8; i++) {
        game.update(1);
      }
      await game.ready();
      expect(hint.isVisible, isFalse);
    },
  );

  testWithGame<FifflarUffeGame>(
    'Uffe leans in front of open popups while talking',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      expect(game.uffe.priority, lessThan(game.router.priority));
      game.router.pushNamed('shop');
      game.update(0);
      await game.ready();
      final skill = skillCatalog.first;
      for (var i = 0; i < skill.basePrice; i++) {
        game.economy.earnClick();
      }
      expect(game.buyItem(skill), isTrue);
      game.update(0.1);
      await game.ready();
      expect(game.uffe.priority, greaterThan(game.router.priority));
      for (var i = 0; i < 5; i++) {
        game.update(1);
      }
      await game.ready();
      expect(game.uffe.priority, lessThan(game.router.priority));
    },
  );

  testWithGame<FifflarUffeGame>(
    'pause route freezes the world',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      game.router.pushNamed('pause');
      game.update(0);
      await game.ready();
      expect(game.world.updatePaused, isTrue);
      game.router.pop();
      game.update(0);
      await game.ready();
      expect(game.world.updatePaused, isFalse);
    },
  );

  testWithGame<FifflarUffeGame>(
    'the pause menu can exit the run and return to the main menu',
    FifflarUffeGame.new,
    (game) async {
      await startRun(game);
      for (var i = 0; i < 5; i++) {
        game.economy.earnClick();
      }
      game.router.pushNamed('pause');
      game.update(0);
      await game.ready();
      final page = game.router.currentRoute.children
          .whereType<PausePage>()
          .single;
      final labels = page.panel.children
          .whereType<GameButton>()
          .map((button) => button.label(game.i18n.strings))
          .toList();
      expect(labels, ['Fortsätt', 'Inställningar', 'Huvudmeny']);
      page.panel.children
          .whereType<GameButton>()
          .firstWhere(
            (button) => button.label(game.i18n.strings) == 'Huvudmeny',
          )
          .onPressed!();
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['mainMenu']);
      expect(game.router.previousRoute, game.router.routes['home']);
      expect(game.world.updatePaused, isTrue);
      expect(game.economy.balance, 0);
      expect(game.economy.totalEarned, 0);
    },
  );

  testWithGame<FifflarUffeGame>(
    'a balance too wide for the counter breaks capitalism',
    FifflarUffeGame.new,
    (game) async {
      await startRun(game);
      game.economy.baseClickValue = 1e15;
      game.economy.earnClick();
      game.update(0);
      await game.ready();
      expect(
        game.router.currentRoute,
        game.router.routes['brokenCapitalism'],
      );
      expect(game.world.updatePaused, isTrue);
      expect(game.highScore, game.economy.totalEarned);
    },
  );

  testWithGame<FifflarUffeGame>(
    'restarting after breaking capitalism allows it to break again',
    FifflarUffeGame.new,
    (game) async {
      await startRun(game);
      game.economy.baseClickValue = 1e15;
      game.economy.earnClick();
      game.update(0);
      await game.ready();
      game.restartRun();
      game.router.pop();
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['home']);
      game.economy.earnClick();
      game.update(0);
      await game.ready();
      expect(
        game.router.currentRoute,
        game.router.routes['brokenCapitalism'],
      );
    },
  );
}
