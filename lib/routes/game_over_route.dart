import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/timeline.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/localized_link_component.dart';
import 'package:fifflar_uffe/ui/localized_text_box_component.dart';
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
    : super(designSize: Vector2(700, 480), dismissOnScrimTap: false);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final narrow = isNarrowScreen;
    resizePanel(narrow ? Vector2(460, 640) : Vector2(700, 480));
    final center = designSize.x / 2;
    final textWidth = narrow ? 396.0 : 580.0;
    panel.addAll([
      PanelComponent(size: designSize.clone()),
      PanelHeader(
        title: (strings) => strings.gameOverTitle,
        size: Vector2(narrow ? 400 : 560, 68),
        position: Vector2(center, 0),
        anchor: Anchor.center,
      ),
      LocalizedTextBoxComponent(
        selector: (strings) => strings.voteAppeal(
          strings.formatDayMonth(Timeline.electionDate),
        ),
        textRenderer: TextStyles.paragraph,
        boxConfig: TextBoxConfig(maxWidth: textWidth),
        align: Anchor.topCenter,
        anchor: Anchor.topCenter,
        position: Vector2(center, 66),
      ),
      LocalizedTextComponent(
        selector: (strings) =>
            '${strings.finalScore}: ${formatSek(game.economy.totalEarned)}',
        textRenderer: TextStyles.body,
        anchor: Anchor.center,
        position: Vector2(center, narrow ? 226 : 186),
      ),
      LocalizedTextComponent(
        selector: (strings) =>
            '${strings.highScoreLabel}: ${formatSek(game.highScore)}',
        textRenderer: TextStyles.info,
        anchor: Anchor.center,
        position: Vector2(center, narrow ? 266 : 228),
      ),
      LocalizedTextBoxComponent(
        selector: (strings) => strings.aboutSatire,
        textRenderer: TextStyles.info,
        boxConfig: TextBoxConfig(maxWidth: textWidth),
        align: Anchor.topCenter,
        anchor: Anchor.topCenter,
        position: Vector2(center, narrow ? 294 : 256),
      ),
      LocalizedLinkComponent(
        selector: (strings) => strings.references,
        url: 'references.html',
        anchor: Anchor.center,
        position: Vector2(center, narrow ? 378 : 320),
      ),
      GameButton(
        label: (strings) => strings.playAgain,
        size: Vector2(280, 92),
        position: narrow ? Vector2(center, 442) : Vector2(center - 160, 396),
        anchor: Anchor.center,
        onPressed: () {
          game.restartRun();
          close();
        },
      ),
      GameButton(
        label: (strings) => strings.continuePlaying,
        color: GameButtonColor.blue,
        size: Vector2(280, 92),
        position: narrow ? Vector2(center, 548) : Vector2(center + 160, 396),
        anchor: Anchor.center,
        onPressed: () {
          game.continueRun();
          close();
        },
      ),
    ]);
  }
}
