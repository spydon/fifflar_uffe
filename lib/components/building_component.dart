import 'dart:math';

import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:fifflar_uffe/model/skill_def.dart';
import 'package:fifflar_uffe/ui/hover_lighten.dart';
import 'package:fifflar_uffe/ui/hud/hud_auto_scale.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/animation.dart';

class BuildingComponent extends PositionComponent
    with
        TapCallbacks,
        HoverCallbacks,
        HoverLighten,
        HasGameRef<FifflarUffeGame> {
  BuildingComponent({required this.skill})
    : super(size: Vector2(104, 130), anchor: Anchor.center);

  static const double _gap = 24;
  static const double _verticalMargin = 180;

  final SkillDef skill;

  static const double _maxParticleRate = 4;

  late final TextComponent _count;
  late final TextComponent _price;
  ParticleEmitterComponent? _coinParticles;
  int _particleLevel = 0;

  @override
  Future<void> onLoad() async {
    addAll([
      SpriteComponent(
        sprite: Sprite(gameRef.images.fromCache(AssetPaths.itemSlot)),
        size: Vector2(96, 104),
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2, 0),
      ),
      SpriteComponent(
        sprite: Sprite(gameRef.images.fromCache(skill.iconPath)),
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
    _updatePosition(gameRef.size);
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(layoutFactor(gameRef.size)),
        EffectController(duration: 0.3, curve: Curves.easeOutBack),
      ),
    );
  }

  static int get _columns =>
      skillCatalog.map((skill) => skill.branch).reduce(max) + 1;

  static int get _rows =>
      skillCatalog.map((skill) => skill.tier).reduce(max) + 1;

  static double _gridHeight(double factor) =>
      (_rows * 130 + (_rows - 1) * _gap) * factor;

  static double layoutFactor(Vector2 gameSize) {
    final widthFactor = HudAutoScale.factorFor(gameSize);
    final available = gameSize.y - _verticalMargin;
    return min(widthFactor, available / _gridHeight(1));
  }

  @override
  void onMount() {
    super.onMount();
    _refresh();
    gameRef.economy.addListener(_refresh);
  }

  @override
  void onRemove() {
    gameRef.economy.removeListener(_refresh);
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
    if (gameRef.buyItem(skill)) {
      add(
        ScaleEffect.by(
          Vector2.all(1.15),
          EffectController(duration: 0.1, alternate: true),
        ),
      );
    }
  }

  void _updatePosition(Vector2 gameSize) {
    final factor = layoutFactor(gameSize);
    final settled = children.whereType<ScaleEffect>().isEmpty;
    if (settled) {
      scale = Vector2.all(factor);
    }
    final gap = _gap * factor;
    final tileWidth = size.x * factor;
    final tileHeight = size.y * factor;
    final columns = _columns;
    final rows = _rows;
    final gridWidth = columns * tileWidth + (columns - 1) * gap;
    final gridHeight = rows * tileHeight + (rows - 1) * gap;
    final left = (gameSize.x - gridWidth) / 2;
    final top = (gameSize.y - gridHeight) / 2;
    position = Vector2(
      left + skill.branch * (tileWidth + gap) + tileWidth / 2,
      top + skill.tier * (tileHeight + gap) + tileHeight / 2,
    );
  }

  void _refresh() {
    final economy = gameRef.economy;
    _count.text = '${economy.ownedCount(skill)}';
    _price.text = formatSek(economy.priceOf(skill));
    _price.textRenderer = economy.canAfford(skill)
        ? TextStyles.priceTag
        : TextStyles.priceTagDisabled;
    _updateParticles();
  }

  void _updateParticles() {
    final level = gameRef.economy.ownedCount(skill);
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
        Sprite(gameRef.images.fromCache(AssetPaths.iconCoin)),
      ),
    );
    add(_coinParticles!);
  }
}
