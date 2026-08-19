import 'dart:ui';

import 'package:fifflar_uffe/components/background_component.dart';
import 'package:fifflar_uffe/components/building_component.dart';
import 'package:fifflar_uffe/components/income_component.dart';
import 'package:fifflar_uffe/components/money_component.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/shop_catalog.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

class PlayWorld extends World with HasGameReference<FifflarUffeGame> {
  static const double topInset = 110;
  static const double edgeInset = 20;

  SpawnComponent? _spawner;
  final Map<String, BuildingComponent> _buildings = {};

  Rect get playRect {
    final size = game.size;
    return Rect.fromLTWH(
      edgeInset,
      topInset,
      size.x - 2 * edgeInset,
      size.y - topInset - edgeInset,
    );
  }

  @override
  Future<void> onLoad() async {
    _spawner = SpawnComponent.periodRange(
      minPeriod: 0.7,
      maxPeriod: 2.0,
      factory: (_) => MoneyComponent(),
      area: Rectangle.fromRect(playRect),
      spawnWhenLoaded: true,
    );
    addAll([BackgroundComponent(), _spawner!, IncomeComponent()]);
    _syncBuildings();
  }

  @override
  void onMount() {
    super.onMount();
    game.economy.addListener(_syncBuildings);
  }

  @override
  void onRemove() {
    game.economy.removeListener(_syncBuildings);
    super.onRemove();
  }

  void _syncBuildings() {
    for (var i = 0; i < shopCatalog.length; i++) {
      final item = shopCatalog[i];
      final owned = game.economy.ownedCount(item) > 0;
      if (owned && !_buildings.containsKey(item.id)) {
        final building = BuildingComponent(item: item, slotIndex: i);
        _buildings[item.id] = building;
        add(building);
      }
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _spawner?.area = Rectangle.fromRect(
      Rect.fromLTWH(
        edgeInset,
        topInset,
        size.x - 2 * edgeInset,
        size.y - topInset - edgeInset,
      ),
    );
  }
}
