import 'dart:math';
import 'dart:ui';

import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/strings.dart';
import 'package:fifflar_uffe/ui/button_spinner.dart';
import 'package:fifflar_uffe/ui/hover_lighten.dart';
import 'package:fifflar_uffe/ui/localized_text_component.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';

enum GameButtonColor {
  green(AssetPaths.buttonWideGreen, AssetPaths.buttonWideLime),
  blue(AssetPaths.buttonWideBlue, AssetPaths.buttonWideTurquoise),
  yellow(AssetPaths.buttonWideYellow, AssetPaths.buttonWideCream);

  const GameButtonColor(this.upSkinPath, this.downSkinPath);

  final String upSkinPath;
  final String downSkinPath;
}

class GameButton extends AdvancedButtonComponent
    with HasGameReference<FifflarUffeGame>, HoverLighten {
  GameButton({
    required this.label,
    required void Function() onPressed,
    Vector2? size,
    this.color = GameButtonColor.green,
    this.iconPath,
    super.position,
    super.anchor,
    super.priority,
  }) : super(onPressed: onPressed, size: size ?? defaultSize.clone());

  static final Vector2 defaultSize = Vector2(216, 80);
  static const double _labelInset = 22;

  final String Function(Strings strings) label;
  final GameButtonColor color;
  final String? iconPath;

  bool _isBusy = false;

  bool get isBusy => _isBusy;

  set isBusy(bool value) {
    if (_isBusy == value) {
      return;
    }
    _isBusy = value;
    if (value) {
      disabledLabel = ButtonSpinner();
      isDisabled = true;
    } else {
      isDisabled = false;
      disabledLabel = null;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    defaultSkin = SpriteComponent(
      sprite: Sprite(game.images.fromCache(color.upSkinPath)),
    );
    downSkin = SpriteComponent(
      sprite: Sprite(game.images.fromCache(color.downSkinPath)),
    );
    disabledSkin = SpriteComponent(
      sprite: Sprite(game.images.fromCache(AssetPaths.buttonWideGray)),
    );
    final icon = iconPath;
    final content = icon == null
        ? LocalizedTextComponent(
            selector: label,
            textRenderer: TextStyles.button,
          )
        : _IconLabel(
            sprite: Sprite(game.images.fromCache(icon)),
            selector: label,
          );
    defaultLabel = content;
    content.size.addListener(() => _fitLabel(content));
    _fitLabel(content);
  }

  void _fitLabel(PositionComponent content) {
    final maxWidth = size.x - 2 * _labelInset;
    final contentWidth = content.size.x;
    final factor = contentWidth > 0 ? min(1.0, maxWidth / contentWidth) : 1.0;
    content.scale = Vector2.all(factor);
  }
}

class _IconLabel extends PositionComponent {
  _IconLabel({required this.sprite, required this.selector});

  static const double _iconSize = 34;
  static const double _outline = 3;
  static const double _gap = 8;
  static final Paint _outlinePaint = Paint()
    ..colorFilter = const ColorFilter.mode(TextStyles.brown, BlendMode.srcIn);
  static final Paint _fillPaint = Paint()
    ..colorFilter = const ColorFilter.mode(
      Color(0xFFFFF6E3),
      BlendMode.srcIn,
    );

  final Sprite sprite;
  final String Function(Strings strings) selector;
  late final PositionComponent _icon;
  late final LocalizedTextComponent _text;

  @override
  Future<void> onLoad() async {
    _icon = PositionComponent(size: Vector2.all(_iconSize))
      ..addAll([
        SpriteComponent(
          sprite: sprite,
          size: Vector2.all(_iconSize + 2 * _outline),
          anchor: Anchor.center,
          position: Vector2.all(_iconSize / 2),
          paint: _outlinePaint,
        ),
        SpriteComponent(
          sprite: sprite,
          size: Vector2.all(_iconSize),
          anchor: Anchor.center,
          position: Vector2.all(_iconSize / 2),
          paint: _fillPaint,
        ),
      ]);
    _text = LocalizedTextComponent(
      selector: selector,
      textRenderer: TextStyles.button,
    );
    addAll([_icon, _text]);
    _text.size.addListener(_layout);
    _layout();
  }

  void _layout() {
    final height = max(_iconSize, _text.size.y);
    size = Vector2(_iconSize + _gap + _text.size.x, height);
    _icon.position = Vector2(0, (height - _iconSize) / 2);
    _text.position = Vector2(_iconSize + _gap, (height - _text.size.y) / 2);
  }
}
