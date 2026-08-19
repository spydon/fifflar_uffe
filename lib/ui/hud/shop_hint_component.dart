import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/localized_text_component.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart' hide Route;

class ShopHintComponent extends HudMarginComponent
    with HasGameReference<FifflarUffeGame>, HasVisibility {
  ShopHintComponent()
    : super(margin: const EdgeInsets.only(bottom: 37, right: 92));

  static const double _threshold = 10;
  static const double _displayDuration = 6;

  late final PositionComponent _content;
  bool _shown = false;
  bool _dismissing = false;

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
      LocalizedTextComponent(
        selector: (strings) => strings.shopHint,
        textRenderer: TextStyles.hint,
        anchor: Anchor.centerRight,
        position: Vector2(size.x - 44, size.y / 2),
      ),
      _ArrowComponent(position: Vector2(size.x - 34, 4)),
    ]);
    add(_content);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_shown) {
      if (game.economy.balance >= _threshold && game.economy.owned.isEmpty) {
        _show();
      }
      return;
    }
    if (isVisible &&
        !_dismissing &&
        game.router.currentRoute == game.router.routes['shop']) {
      _dismiss();
    }
  }

  void _show() {
    _shown = true;
    isVisible = true;
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

  void _dismiss() {
    if (_dismissing) {
      return;
    }
    _dismissing = true;
    _content.add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.25, curve: Curves.easeIn),
        onComplete: () => isVisible = false,
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
