import 'dart:ui';

import 'package:fifflar_uffe/components/income_component.dart';
import 'package:fifflar_uffe/components/money_component.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

class PlayWorld extends World with HasGameReference<FifflarUffeGame> {
  static const double topInset = 110;
  static const double edgeInset = 20;

  SpawnComponent? _spawner;

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
    addAll([_spawner!, IncomeComponent()]);
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
