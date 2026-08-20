import 'dart:math';

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
import 'package:flame/particles.dart';
import 'package:flutter/animation.dart';

class BuildingComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FifflarUffeGame> {
  BuildingComponent({required this.skill, required this.slotIndex})
    : super(size: Vector2(104, 130), anchor: Anchor.center);

  final SkillDef skill;
  final int slotIndex;

  static const double _maxParticleRate = 4;

  late final TextComponent _count;
  late final TextComponent _price;
  ParticleEmitterComponent? _coinParticles;
  int _particleLevel = 0;

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
    _updateParticles();
  }

  void _updateParticles() {
    final level = game.economy.ownedCount(skill);
    if (level == _particleLevel && _coinParticles != null) {
      return;
    }
    _particleLevel = level;
    _coinParticles?.removeFromParent();
    if (level == 0) {
      _coinParticles = null;
      return;
    }
    final speedBoost = 1 + 0.15 * (min(level, 10) - 1);
    _coinParticles = ParticleEmitterComponent(
      position: Vector2(size.x / 2, 52),
      emitter: ParticleEmitter(
        maxParticles: 16,
        rate: min(level.toDouble(), _maxParticleRate),
        lifespan: (1.0, 1.6),
        shape: const CircleEmitterShape(56, edgeOnly: true),
        speed: (12 * speedBoost, 26 * speedBoost),
        direction: -pi / 2,
        spread: 1,
        size: (10, 15),
        opacityOverLife: ParticleCurve(1, 0, curve: Curves.easeIn),
        scaleOverLife: ParticleCurve(1, 0.6),
      ),
      renderer: SpriteParticleRenderer(
        Sprite(game.images.fromCache(AssetPaths.iconCoin)),
      ),
    );
    add(_coinParticles!);
  }
}
