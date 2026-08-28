import 'package:fifflar_uffe/components/uffe_swarm_component.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/economy.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/localized_text_box_component.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class BrokenCapitalismRoute extends Route
    with HasGameReference<FifflarUffeGame> {
  BrokenCapitalismRoute()
    : super(
        BrokenCapitalismPage.new,
        transparent: true,
        maintainState: false,
      );

  @override
  void onPush(Route? previousRoute) {
    game.world.updatePaused = true;
  }

  @override
  void onPop(Route nextRoute) {
    game.world.updatePaused = false;
  }
}

class BrokenCapitalismPage extends ModalPage {
  BrokenCapitalismPage()
    : super(designSize: Vector2(560, 300), dismissOnScrimTap: false);

  late final PanelComponent _background;
  late final LocalizedTextBoxComponent _message;
  late final LocalizedTextBoxComponent _note;
  late final GameButton _playAgain;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    scrim.priority = -2;
    add(UffeSwarmComponent(priority: -1));
    final narrow = isNarrowScreen;
    if (narrow) {
      resizePanel(Vector2(460, designSize.y));
    }
    final center = designSize.x / 2;
    panel.addAll([
      _background = PanelComponent(size: designSize.clone()),
      _message = LocalizedTextBoxComponent(
        selector: (strings) => strings.brokeCapitalism,
        textRenderer: TextStyles.enlarged(TextStyles.body, narrow ? 1.5 : 1.4),
        boxConfig: TextBoxConfig(maxWidth: designSize.x - 120),
        align: Anchor.topCenter,
        anchor: Anchor.topCenter,
        position: Vector2(center, 56),
      ),
      _note = LocalizedTextBoxComponent(
        selector: (strings) => strings.capitalismLimitNote(
          formatSek(Economy.capitalismLimit),
        ),
        textRenderer: narrow
            ? TextStyles.enlarged(TextStyles.paragraph, 1.15)
            : TextStyles.paragraph,
        boxConfig: TextBoxConfig(maxWidth: designSize.x - 80),
        align: Anchor.topCenter,
        anchor: Anchor.topCenter,
      ),
      _playAgain = GameButton(
        label: (strings) => strings.playAgain,
        anchor: Anchor.center,
        onPressed: () {
          game.restartRun();
          close();
        },
      ),
    ]);
    _message.size.addListener(_layoutContent);
    _note.size.addListener(_layoutContent);
    _layoutContent();
  }

  void _layoutContent() {
    final center = designSize.x / 2;
    _note.position = Vector2(
      center,
      _message.position.y + _message.size.y + 18,
    );
    final y = _note.position.y + _note.size.y + 30;
    _playAgain.position = Vector2(center, y + 40);
    final height = y + 80 + 36;
    _background.size = Vector2(designSize.x, height);
    resizePanel(Vector2(designSize.x, height));
  }
}
