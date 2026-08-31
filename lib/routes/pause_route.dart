import 'dart:async';

import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class PauseRoute extends Route with HasGameRef<FifflarUffeGame> {
  PauseRoute() : super(PausePage.new, transparent: true, maintainState: false);

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

class PausePage extends ModalPage {
  PausePage() : super(designSize: Vector2(560, 420), dismissOnScrimTap: false);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (isNarrowScreen) {
      resizePanel(Vector2(460, designSize.y));
    }
    final center = designSize.x / 2;
    panel.addAll([
      PanelComponent(size: designSize.clone()),
      PanelHeader(
        title: (strings) => strings.pauseTitle,
        size: Vector2(360, 68),
        position: Vector2(center, 0),
        anchor: Anchor.center,
      ),
      GameButton(
        label: (strings) => strings.resume,
        anchor: Anchor.center,
        position: Vector2(center, 104),
        onPressed: close,
      ),
      GameButton(
        label: (strings) => strings.settings,
        iconPath: AssetPaths.iconGear,
        color: GameButtonColor.blue,
        anchor: Anchor.center,
        position: Vector2(center, 200),
        onPressed: () => gameRef.router.pushNamed('settings'),
      ),
      GameButton(
        label: (strings) => strings.mainMenu,
        color: GameButtonColor.blue,
        anchor: Anchor.center,
        position: Vector2(center, 296),
        onPressed: () {
          gameRef.restartRun();
          gameRef.router.pushNamed('mainMenu', replace: true);
        },
      ),
    ]);
  }
}
