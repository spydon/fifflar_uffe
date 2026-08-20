import 'dart:async';

import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/i18n.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/language_flag_button.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class PauseRoute extends Route with HasGameReference<FifflarUffeGame> {
  PauseRoute() : super(PausePage.new, transparent: true, maintainState: false);

  @override
  void onPush(Route? previousRoute) {
    game.world.updatePaused = true;
    unawaited(game.highscore.probe());
  }

  @override
  void onPop(Route nextRoute) {
    game.world.updatePaused = false;
  }
}

class PausePage extends ModalPage {
  PausePage() : super(designSize: Vector2(560, 520), dismissOnScrimTap: false);

  static const double _firstButtonY = 200;
  static const double _buttonSpacing = 110;
  static const double _bottomPadding = 100;

  late final PanelComponent _background;
  late final GameButton _resume;
  late final GameButton _highscores;
  late final GameButton _restart;
  late final GameButton _about;
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
        title: (strings) => strings.pauseTitle,
        size: Vector2(360, 68),
        position: Vector2(center, 0),
        anchor: Anchor.center,
      ),
      LanguageFlagButton(
        language: AppLanguage.sv,
        position: Vector2(center - 66, 100),
        anchor: Anchor.center,
      ),
      LanguageFlagButton(
        language: AppLanguage.en,
        position: Vector2(center + 66, 100),
        anchor: Anchor.center,
      ),
      _resume = GameButton(
        label: (strings) => strings.resume,
        size: Vector2(250, 92),
        anchor: Anchor.center,
        onPressed: close,
      ),
      _restart = GameButton(
        label: (strings) => strings.restart,
        color: GameButtonColor.blue,
        size: Vector2(250, 92),
        anchor: Anchor.center,
        onPressed: () {
          game.restartRun();
          close();
        },
      ),
      _about = GameButton(
        label: (strings) => strings.about,
        color: GameButtonColor.blue,
        size: Vector2(250, 92),
        anchor: Anchor.center,
        onPressed: () => game.router.pushNamed('about'),
      ),
    ]);
    _highscores = GameButton(
      label: (strings) => strings.highscores,
      color: GameButtonColor.yellow,
      size: Vector2(250, 92),
      anchor: Anchor.center,
      onPressed: () => game.router.pushNamed('highscore'),
    );
    _built = true;
    _layoutButtons();
  }

  @override
  void onMount() {
    super.onMount();
    game.highscore.available.addListener(_layoutButtons);
  }

  @override
  void onRemove() {
    game.highscore.available.removeListener(_layoutButtons);
    super.onRemove();
  }

  void _layoutButtons() {
    if (!_built) {
      return;
    }
    final showHighscores = game.highscore.available.value;
    if (showHighscores && _highscores.parent == null) {
      panel.add(_highscores);
    } else if (!showHighscores && _highscores.parent != null) {
      _highscores.removeFromParent();
    }
    final buttons = [
      _resume,
      if (showHighscores) _highscores,
      _restart,
      _about,
    ];
    final center = designSize.x / 2;
    var y = _firstButtonY;
    for (final button in buttons) {
      button.position = Vector2(center, y);
      y += _buttonSpacing;
    }
    final height = y - _buttonSpacing + _bottomPadding;
    _background.size = Vector2(designSize.x, height);
    resizePanel(Vector2(designSize.x, height));
  }
}
