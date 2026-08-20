import 'dart:typed_data';

import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/timeline.dart';
import 'package:fifflar_uffe/services/share_service.dart';
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

  late final PanelComponent _background;
  late final LocalizedTextBoxComponent _appeal;
  late final LocalizedTextComponent _finalScore;
  late final LocalizedTextComponent _highScore;
  late final LocalizedTextBoxComponent _satire;
  late final LocalizedLinkComponent _referencesLink;
  late final GameButton _playAgain;
  late final GameButton _continue;
  late final GameButton _share;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final narrow = isNarrowScreen;
    resizePanel(narrow ? Vector2(460, 640) : Vector2(700, 480));
    final center = designSize.x / 2;
    final textWidth = narrow ? 396.0 : 580.0;
    final bodyStyle = narrow
        ? TextStyles.enlarged(TextStyles.paragraph, 1.3)
        : TextStyles.paragraph;
    final infoStyle = narrow
        ? TextStyles.enlarged(TextStyles.info, 1.25)
        : TextStyles.info;
    final linkStyle = narrow
        ? TextStyles.enlarged(TextStyles.eventLink, 1.3)
        : TextStyles.eventLink;
    panel.addAll([
      _background = PanelComponent(size: designSize.clone()),
      PanelHeader(
        title: (strings) => strings.gameOverTitle,
        size: Vector2(narrow ? 400 : 560, 68),
        position: Vector2(center, 0),
        anchor: Anchor.center,
      ),
      _appeal = LocalizedTextBoxComponent(
        selector: (strings) => strings.voteAppeal(
          strings.formatDayMonth(Timeline.electionDate),
        ),
        textRenderer: bodyStyle,
        boxConfig: TextBoxConfig(maxWidth: textWidth),
        align: Anchor.topCenter,
        anchor: Anchor.topCenter,
        position: Vector2(center, 62),
      ),
      _finalScore = LocalizedTextComponent(
        selector: (strings) =>
            '${strings.finalScore}: ${formatSek(game.economy.totalEarned)}',
        textRenderer: narrow
            ? TextStyles.enlarged(TextStyles.body, 1.15)
            : TextStyles.body,
        anchor: Anchor.center,
      ),
      _highScore = LocalizedTextComponent(
        selector: (strings) =>
            '${strings.highScoreLabel}: ${formatSek(game.highScore)}',
        textRenderer: infoStyle,
        anchor: Anchor.center,
      ),
      _satire = LocalizedTextBoxComponent(
        selector: (strings) => strings.aboutSatire,
        textRenderer: infoStyle,
        boxConfig: TextBoxConfig(maxWidth: textWidth),
        align: Anchor.topCenter,
        anchor: Anchor.topCenter,
      ),
      _referencesLink = LocalizedLinkComponent(
        selector: (strings) => strings.references,
        url: 'references.html',
        textRenderer: linkStyle,
        anchor: Anchor.center,
      ),
      _playAgain = GameButton(
        label: (strings) => strings.playAgain,
        size: Vector2(280, 92),
        anchor: Anchor.center,
        onPressed: () {
          game.restartRun();
          close();
        },
      ),
      _continue = GameButton(
        label: (strings) => strings.continuePlaying,
        color: GameButtonColor.blue,
        size: Vector2(280, 92),
        anchor: Anchor.center,
        onPressed: () {
          game.continueRun();
          close();
        },
      ),
      _share = GameButton(
        label: (strings) => strings.share,
        color: GameButtonColor.yellow,
        size: Vector2(280, 92),
        anchor: Anchor.center,
        onPressed: _shareResult,
      ),
    ]);
    _appeal.size.addListener(_layoutContent);
    _satire.size.addListener(_layoutContent);
    _layoutContent();
  }

  void _layoutContent() {
    final narrow = isNarrowScreen;
    final center = designSize.x / 2;
    var y = _appeal.position.y + _appeal.size.y + 24;
    _finalScore.position = Vector2(center, y);
    y += 42;
    _highScore.position = Vector2(center, y);
    y += 24;
    _satire.position = Vector2(center, y);
    y += _satire.size.y + 20;
    _referencesLink.position = Vector2(center, y);
    y += 42;
    if (narrow) {
      _playAgain.position = Vector2(center, y + 46);
      _continue.position = Vector2(center, y + 152);
      _share.position = Vector2(center, y + 258);
      y += 258 + 46 + 30;
    } else {
      _playAgain.position = Vector2(center - 160, y + 46);
      _continue.position = Vector2(center + 160, y + 46);
      _share.position = Vector2(center, y + 152);
      y += 152 + 46 + 30;
    }
    _background.size = Vector2(designSize.x, y);
    resizePanel(Vector2(designSize.x, y));
  }

  Future<void> _shareResult() async {
    if (_share.isBusy) {
      return;
    }
    _share.isBusy = true;
    final Uint8List bytes;
    try {
      bytes = await ShareService.renderCard(game);
    } finally {
      if (isMounted) {
        _share.isBusy = false;
      }
    }
    await ShareService.shareCard(game, bytes);
  }
}
