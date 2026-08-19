import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/localized_text_component.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class GameOverRoute extends Route with HasGameReference<FifflarUffeGame> {
  GameOverRoute()
    : super(GameOverPage.new, transparent: true, maintainState: false);

  @override
  void onPush(Route? previousRoute) {
    game.world.updatePaused = true;
  }

  @override
  void onPop(Route nextRoute) {
    game.world.updatePaused = false;
  }
}

class GameOverPage extends ModalPage {
  GameOverPage()
    : super(designSize: Vector2(700, 440), dismissOnScrimTap: false);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    panel.addAll([
      PanelComponent(size: designSize),
      PanelHeader(
        title: (strings) => strings.gameOverTitle,
        size: Vector2(520, 68),
        position: Vector2(designSize.x / 2, 0),
        anchor: Anchor.center,
      ),
      LocalizedTextComponent(
        selector: (strings) =>
            '${strings.finalScore}: ${formatSek(game.economy.totalEarned)}',
        textRenderer: TextStyles.body,
        anchor: Anchor.center,
        position: Vector2(designSize.x / 2, 160),
      ),
      LocalizedTextComponent(
        selector: (strings) =>
            '${strings.highScoreLabel}: ${formatSek(game.highScore)}',
        textRenderer: TextStyles.info,
        anchor: Anchor.center,
        position: Vector2(designSize.x / 2, 210),
      ),
      GameButton(
        label: (strings) => strings.playAgain,
        size: Vector2(280, 92),
        position: Vector2(designSize.x / 2, 330),
        anchor: Anchor.center,
        onPressed: () {
          game.restartRun();
          close();
        },
      ),
    ]);
  }
}
