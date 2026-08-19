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
  }

  @override
  void onPop(Route nextRoute) {
    game.world.updatePaused = false;
  }
}

class PausePage extends ModalPage {
  PausePage() : super(designSize: Vector2(560, 520), dismissOnScrimTap: false);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (isNarrowScreen) {
      resizePanel(Vector2(460, designSize.y));
    }
    panel.addAll([
      PanelComponent(size: designSize.clone()),
      PanelHeader(
        title: (strings) => strings.pauseTitle,
        size: Vector2(360, 68),
        position: Vector2(designSize.x / 2, 0),
        anchor: Anchor.center,
      ),
      LanguageFlagButton(
        language: AppLanguage.sv,
        position: Vector2(designSize.x / 2 - 66, 100),
        anchor: Anchor.center,
      ),
      LanguageFlagButton(
        language: AppLanguage.en,
        position: Vector2(designSize.x / 2 + 66, 100),
        anchor: Anchor.center,
      ),
      GameButton(
        label: (strings) => strings.resume,
        size: Vector2(250, 92),
        position: Vector2(designSize.x / 2, 200),
        anchor: Anchor.center,
        onPressed: close,
      ),
      GameButton(
        label: (strings) => strings.restart,
        color: GameButtonColor.blue,
        size: Vector2(250, 92),
        position: Vector2(designSize.x / 2, 310),
        anchor: Anchor.center,
        onPressed: () {
          game.restartRun();
          close();
        },
      ),
      GameButton(
        label: (strings) => strings.about,
        color: GameButtonColor.blue,
        size: Vector2(250, 92),
        position: Vector2(designSize.x / 2, 420),
        anchor: Anchor.center,
        onPressed: () => game.router.pushNamed('about'),
      ),
    ]);
  }
}
