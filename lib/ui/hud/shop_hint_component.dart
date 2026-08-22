import 'dart:math';

import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:fifflar_uffe/model/skill_def.dart';
import 'package:fifflar_uffe/model/skill_id.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart' hide Route;

class ShopHintComponent extends HudMarginComponent
    with HasGameReference<FifflarUffeGame>, HasVisibility {
  ShopHintComponent()
    : super(margin: const EdgeInsets.only(bottom: 37, right: 92));

  static const double _displayDuration = 6;
  static const double _arrowReserve = 44;
  static const double _sideMargins = 104;

  late final PositionComponent _content;
  late final TextComponent _text;
  late final _ArrowComponent _arrow;
  final Set<SkillId> _announced = {};
  bool _showing = false;
  bool _dismissing = false;

  @override
  void onGameResize(Vector2 gameSize) {
    if (isLoaded) {
      _updateScale(gameSize);
    }
    super.onGameResize(gameSize);
  }

  @override
  Future<void> onLoad() async {
    size = Vector2(260, 30);
    isVisible = false;
    _content = PositionComponent(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    _content.addAll([
      _text = TextComponent(
        textRenderer: TextStyles.hint,
        anchor: Anchor.centerRight,
        position: Vector2(size.x - _arrowReserve, size.y / 2),
      ),
      _arrow = _ArrowComponent(position: Vector2(size.x - 34, 4)),
    ]);
    add(_content);
    _updateScale(game.size);
  }

  void resetRun() {
    _announced.clear();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_showing) {
      if (isVisible &&
          !_dismissing &&
          game.router.currentRoute == game.router.routes['shop']) {
        _dismiss();
      }
      return;
    }
    final economy = game.economy;
    for (final skill in skillCatalog) {
      if (_announced.contains(skill.id) ||
          economy.ownedCount(skill) > 0 ||
          !economy.isUnlocked(skill) ||
          !economy.canAfford(skill)) {
        continue;
      }
      _announced.add(skill.id);
      _show(skill);
      break;
    }
  }

  void _show(SkillDef skill) {
    final strings = game.i18n.strings;
    _text.text = game.economy.owned.isEmpty
        ? strings.shopHint
        : strings.affordHint(skill.name(strings));
    _layout();
    _showing = true;
    _dismissing = false;
    isVisible = true;
    priority = game.router.priority + 2;
    _content.scale = Vector2.zero();
    _content.addAll([
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.3, curve: Curves.easeOutBack),
      ),
      MoveByEffect(
        Vector2(8, 0),
        EffectController(duration: 0.4, alternate: true, infinite: true),
      ),
    ]);
    add(
      TimerComponent(
        period: _displayDuration,
        removeOnFinish: true,
        onTick: _dismiss,
      ),
    );
  }

  void _layout() {
    size = Vector2(_text.size.x + _arrowReserve + 6, 30);
    _content.size = size;
    _content.position = size / 2;
    _text.position = Vector2(size.x - _arrowReserve, size.y / 2);
    _arrow.position = Vector2(size.x - 34, 4);
    onGameResize(game.size);
  }

  void _updateScale(Vector2 gameSize) {
    scale = Vector2.all(min(1, (gameSize.x - _sideMargins) / size.x));
  }

  void _dismiss() {
    if (_dismissing) {
      return;
    }
    _dismissing = true;
    for (final effect in _content.children.whereType<Effect>().toList()) {
      effect.removeFromParent();
    }
    _content.add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.25, curve: Curves.easeIn),
        onComplete: () {
          isVisible = false;
          _showing = false;
          _dismissing = false;
          priority = 0;
          _content.position = size / 2;
        },
      ),
    );
  }
}

class _ArrowComponent extends PolygonComponent {
  _ArrowComponent({super.position})
    : super(
        [
          Vector2(0, 7),
          Vector2(16, 7),
          Vector2(16, 0),
          Vector2(28, 11),
          Vector2(16, 22),
          Vector2(16, 15),
          Vector2(0, 15),
        ],
        paint: Paint()..color = const Color(0xFFFFF6E3),
      );
}
