import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/strings.dart';
import 'package:fifflar_uffe/ui/button_spinner.dart';
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
    with HasGameReference<FifflarUffeGame> {
  GameButton({
    required this.label,
    required void Function() onPressed,
    required Vector2 size,
    this.color = GameButtonColor.green,
    super.position,
    super.anchor,
    super.priority,
  }) : super(onPressed: onPressed, size: size);

  final String Function(Strings strings) label;
  final GameButtonColor color;

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
    defaultLabel = LocalizedTextComponent(
      selector: label,
      textRenderer: TextStyles.button,
    );
  }
}
