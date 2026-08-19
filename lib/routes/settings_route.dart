import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/i18n.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_close_button.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class SettingsRoute extends Route {
  SettingsRoute() : super(SettingsPage.new, transparent: true);
}

class SettingsPage extends ModalPage {
  SettingsPage() : super(designSize: Vector2(560, 430));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    panel.addAll([
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.panelNotebook)),
        size: designSize,
      ),
      PanelHeader(
        title: (strings) => strings.settingsTitle,
        size: Vector2(360, 68),
        position: Vector2(designSize.x / 2, 0),
        anchor: Anchor.center,
      ),
      PanelCloseButton(
        position: Vector2(designSize.x - 16, 16),
        anchor: Anchor.center,
        onPressed: () => game.router.pop(),
      ),
      LanguageRadioRow(
        language: AppLanguage.sv,
        label: 'Svenska',
        position: Vector2(designSize.x / 2, 205),
        anchor: Anchor.center,
      ),
      LanguageRadioRow(
        language: AppLanguage.en,
        label: 'English',
        position: Vector2(designSize.x / 2, 270),
        anchor: Anchor.center,
      ),
      GameButton(
        label: (strings) => strings.about,
        color: GameButtonColor.blue,
        size: Vector2(220, 82),
        position: Vector2(designSize.x / 2, 360),
        anchor: Anchor.center,
        onPressed: () => game.router.pushNamed('about'),
      ),
    ]);
  }
}

class LanguageRadioRow extends PositionComponent
    with TapCallbacks, HasGameReference<FifflarUffeGame> {
  LanguageRadioRow({
    required this.language,
    required this.label,
    super.position,
    super.anchor,
  }) : super(size: Vector2(240, 56));

  final AppLanguage language;
  final String label;

  late final SpriteGroupComponent<bool> _radio;

  @override
  Future<void> onLoad() async {
    _radio = SpriteGroupComponent<bool>(
      sprites: {
        true: Sprite(game.images.fromCache(AssetPaths.radioChecked)),
        false: Sprite(game.images.fromCache(AssetPaths.radioUnchecked)),
      },
      current: game.i18n.language.value == language,
      size: Vector2(40, 42),
      anchor: Anchor.centerLeft,
      position: Vector2(0, size.y / 2),
    );
    add(_radio);
    add(
      TextComponent(
        text: label,
        textRenderer: TextStyles.body,
        anchor: Anchor.centerLeft,
        position: Vector2(60, size.y / 2),
      ),
    );
  }

  @override
  void onMount() {
    super.onMount();
    game.i18n.language.addListener(_refresh);
  }

  @override
  void onRemove() {
    game.i18n.language.removeListener(_refresh);
    super.onRemove();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.i18n.language.value = language;
  }

  void _refresh() {
    _radio.current = game.i18n.language.value == language;
  }
}
