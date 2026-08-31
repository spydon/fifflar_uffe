import 'dart:async';

import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/localized_inline_link_component.dart';
import 'package:fifflar_uffe/ui/menu_note_component.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class MainMenuRoute extends Route with HasGameRef<FifflarUffeGame> {
  MainMenuRoute()
    : super(MainMenuPage.new, transparent: true, maintainState: false);

  @override
  void onPush(Route? previousRoute) {
    gameRef.world.updatePaused = true;
    unawaited(gameRef.highscore.probe());
  }

  @override
  void onPop(Route nextRoute) {
    gameRef.world.updatePaused = false;
  }
}

class MainMenuPage extends ModalPage {
  MainMenuPage()
    : super(designSize: Vector2(560, 520), dismissOnScrimTap: false);

  static const double _noteTop = 54;
  static const double _noteInset = 40;
  static const double _noteToButtonGap = 66;
  static const double _buttonSpacing = 96;
  static const double _buttonToPromptGap = 18;
  static const double _promptInset = 40;
  static const double _bottomPadding = 30;

  late final PanelComponent _background;
  late final MenuNoteComponent _note;
  late final GameButton _start;
  late final GameButton _highscores;
  late final GameButton _settings;
  late final GameButton _about;
  late final LocalizedInlineLinkComponent _referencesPrompt;
  bool _built = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (isNarrowScreen) {
      resizePanel(Vector2(460, designSize.y));
    }
    final center = designSize.x / 2;
    panel.addAll([
      _background = PanelComponent(size: designSize.clone()),
      PanelHeader(
        title: (strings) => strings.mainMenuTitle,
        size: Vector2(360, 68),
        position: Vector2(center, 0),
        anchor: Anchor.center,
      ),
      _note = MenuNoteComponent(
        selector: (strings) => strings.mainMenuNote,
        textRenderer: isNarrowScreen
            ? TextStyles.enlarged(TextStyles.note, 1.2)
            : TextStyles.note,
        width: designSize.x - 2 * _noteInset,
        position: Vector2(center, _noteTop),
        anchor: Anchor.topCenter,
      ),
      _start = GameButton(
        label: (strings) => strings.startPlaying,
        anchor: Anchor.center,
        onPressed: close,
      ),
      _settings = GameButton(
        label: (strings) => strings.settings,
        iconPath: AssetPaths.iconGear,
        color: GameButtonColor.blue,
        anchor: Anchor.center,
        onPressed: () => gameRef.router.pushNamed('settings'),
      ),
      _about = GameButton(
        label: (strings) => strings.about,
        color: GameButtonColor.blue,
        anchor: Anchor.center,
        onPressed: () => gameRef.router.pushNamed('about'),
      ),
      _referencesPrompt = LocalizedInlineLinkComponent(
        selector: (strings) => strings.mainMenuReferencesPrompt,
        url: 'references.html',
        textRenderer: isNarrowScreen
            ? TextStyles.enlarged(TextStyles.info, 1.2)
            : TextStyles.info,
        linkRenderer: isNarrowScreen
            ? TextStyles.enlarged(TextStyles.infoLink, 1.2)
            : TextStyles.infoLink,
        maxWidth: designSize.x - 2 * _promptInset,
        anchor: Anchor.topCenter,
      ),
    ]);
    _highscores = GameButton(
      label: (strings) => strings.highscores,
      color: GameButtonColor.yellow,
      anchor: Anchor.center,
      onPressed: () => gameRef.router.pushNamed('highscore'),
    );
    _built = true;
    _note.size.addListener(_layoutButtons);
    _referencesPrompt.size.addListener(_layoutButtons);
    _layoutButtons();
  }

  @override
  void onMount() {
    super.onMount();
    gameRef.highscore.available.addListener(_layoutButtons);
  }

  @override
  void onRemove() {
    gameRef.highscore.available.removeListener(_layoutButtons);
    super.onRemove();
  }

  void _layoutButtons() {
    if (!_built) {
      return;
    }
    final showHighscores = gameRef.highscore.available.value;
    if (showHighscores && _highscores.parent == null) {
      panel.add(_highscores);
    } else if (!showHighscores && _highscores.parent != null) {
      _highscores.removeFromParent();
    }
    final buttons = [
      _start,
      if (showHighscores) _highscores,
      _settings,
      _about,
    ];
    final center = designSize.x / 2;
    var y = _note.position.y + _note.size.y + _noteToButtonGap;
    for (final button in buttons) {
      button.position = Vector2(center, y);
      y += _buttonSpacing;
    }
    final promptTop =
        y - _buttonSpacing + GameButton.defaultSize.y / 2 + _buttonToPromptGap;
    _referencesPrompt.position = Vector2(center, promptTop);
    final height = promptTop + _referencesPrompt.size.y + _bottomPadding;
    _background.size = Vector2(designSize.x, height);
    resizePanel(Vector2(designSize.x, height));
  }
}
