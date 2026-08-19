import 'dart:math';

import 'package:fifflar_uffe/components/floating_text_component.dart';
import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:fifflar_uffe/model/skill_def.dart';
import 'package:fifflar_uffe/ui/hud/hud_auto_scale.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';

class BuildingComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FifflarUffeGame> {
  BuildingComponent({required this.skill, required this.slotIndex})
    : super(size: Vector2(104, 130), anchor: Anchor.center);

  final SkillDef skill;
  final int slotIndex;

  late final TextComponent _count;
  late final TextComponent _price;

  @override
  Future<void> onLoad() async {
    addAll([
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.itemSlot)),
        size: Vector2(96, 104),
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2, 0),
      ),
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(skill.iconPath)),
        size: Vector2.all(56),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, 50),
      ),
      _count = TextComponent(
        textRenderer: TextStyles.tileCount,
        anchor: Anchor.topRight,
        position: Vector2(size.x / 2 + 38, 8),
      ),
      _price = TextComponent(
        textRenderer: TextStyles.priceTag,
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2, 108),
      ),
    ]);
    _updatePosition(game.size);
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(HudAutoScale.factorFor(game.size)),
        EffectController(duration: 0.3, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void onMount() {
    super.onMount();
    _refresh();
    game.economy.addListener(_refresh);
  }

  @override
  void onRemove() {
    game.economy.removeListener(_refresh);
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _updatePosition(size);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (game.buyItem(skill)) {
      add(
        ScaleEffect.by(
          Vector2.all(1.15),
          EffectController(duration: 0.1, alternate: true),
        ),
      );
      if (skill.isClickMultiplier) {
        game.world.add(
          FloatingTextComponent(
            text: 'x${game.economy.clickMultiplier}',
            position: position - Vector2(0, size.y / 2 + 12),
          ),
        );
      }
    }
  }

  void _updatePosition(Vector2 gameSize) {
    final factor = HudAutoScale.factorFor(gameSize);
    final pop = children.whereType<ScaleEffect>().isEmpty;
    if (pop) {
      scale = Vector2.all(factor);
    }
    final gap = 24.0 * factor;
    final tileWidth = size.x * factor;
    final tileHeight = size.y * factor;
    final columns = max(
      1,
      min(4, ((gameSize.x - 40) / (tileWidth + gap)).floor()),
    );
    final rows = (skillCatalog.length / columns).ceil();
    final row = slotIndex ~/ columns;
    final column = slotIndex % columns;
    final gridWidth = columns * tileWidth + (columns - 1) * gap;
    final gridHeight = rows * tileHeight + (rows - 1) * gap;
    final left = (gameSize.x - gridWidth) / 2;
    final top = (gameSize.y - gridHeight) / 2;
    position = Vector2(
      left + column * (tileWidth + gap) + tileWidth / 2,
      top + row * (tileHeight + gap) + tileHeight / 2,
    );
  }

  void _refresh() {
    final economy = game.economy;
    _count.text = '${economy.ownedCount(skill)}';
    _price.text = formatSek(economy.priceOf(skill));
    _price.textRenderer = economy.canAfford(skill)
        ? TextStyles.priceTag
        : TextStyles.priceTagDisabled;
  }
}
