import 'dart:convert';

import 'package:fifflar_uffe/components/building_component.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:fifflar_uffe/model/skill_id.dart';
import 'package:fifflar_uffe/model/timeline.dart';
import 'package:fifflar_uffe/ui/hud/event_card_component.dart';
import 'package:fifflar_uffe/ui/hud/shop_hint_component.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWithGame<FifflarUffeGame>(
    'game loads with the home route active',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['home']);
      expect(game.world.updatePaused, isFalse);
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
      game.router.pushNamed('shop');
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['shop']);
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
    'a balance too wide for the counter breaks capitalism',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
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
      game.update(0);
      await game.ready();
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
