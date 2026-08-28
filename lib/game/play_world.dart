import 'dart:ui';

import 'package:fifflar_uffe/components/background_component.dart';
import 'package:fifflar_uffe/components/building_component.dart';
import 'package:fifflar_uffe/components/floating_text_component.dart';
import 'package:fifflar_uffe/components/income_component.dart';
import 'package:fifflar_uffe/components/money_component.dart';
import 'package:fifflar_uffe/components/timeline_component.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:fifflar_uffe/model/skill_id.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

class PlayWorld extends World
    with HasGameReference<FifflarUffeGame>, HasTimeScale {
  static const double topInset = 110;
  static const double edgeInset = 20;

  SpawnComponent? _spawner;
  final Map<SkillId, BuildingComponent> _buildings = {};

  bool updatePaused = false;

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
    addAll([
      BackgroundComponent(),
      _spawner!,
      IncomeComponent(),
      TimelineComponent(),
    ]);
    _syncBuildings();
  }

  void resetRun() {
    final runComponents = [
      ...children.whereType<MoneyComponent>(),
      ...children.whereType<FloatingTextComponent>(),
      ..._buildings.values,
    ];
    for (final component in runComponents) {
      component.removeFromParent();
    }
    _buildings.clear();
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
    for (final skill in skillCatalog) {
      final owned = game.economy.ownedCount(skill) > 0;
      if (owned && !_buildings.containsKey(skill.id)) {
        final building = BuildingComponent(skill: skill);
        _buildings[skill.id] = building;
        add(building);
      }
    }
  }

  @override
  void updateSubtree(double dt) {
    if (updatePaused) {
      return;
    }
    super.updateSubtree(dt);
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
