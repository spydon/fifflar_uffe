import 'dart:convert';

import 'package:fifflar_uffe/components/building_component.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/shop_catalog.dart';
import 'package:fifflar_uffe/model/timeline.dart';
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
    'a building appears after the first purchase of an item',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      expect(game.world.children.whereType<BuildingComponent>(), isEmpty);
      final item = shopCatalog.first;
      for (var i = 0; i < item.basePrice; i++) {
        game.economy.earnClick();
      }
      expect(game.buyItem(item), isTrue);
      game.update(0);
      await game.ready();
      final buildings = game.world.children.whereType<BuildingComponent>();
      expect(buildings.map((building) => building.item.id), [item.id]);
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
      expect(buildings.map((building) => building.item.id), ['lower_taxes']);
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
}
