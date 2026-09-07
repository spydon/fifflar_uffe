import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/localized_text_box_component.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_close_button.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:url_launcher/url_launcher.dart';

const playStoreUrl =
    'https://play.google.com/store/apps/details?id=se.spydon.fifflar_uffe';

class PlayStoreRoute extends Route {
  PlayStoreRoute()
    : super(PlayStorePage.new, transparent: true, maintainState: false);
}

class PlayStorePage extends ModalPage {
  PlayStorePage() : super(designSize: Vector2(520, 260));

  late final PanelComponent _background;
  late final LocalizedTextBoxComponent _note;
  late final GameButton _open;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final narrow = isNarrowScreen;
    if (narrow) {
      resizePanel(Vector2(460, designSize.y));
    }
    final center = designSize.x / 2;
    panel.addAll([
      _background = PanelComponent(size: designSize.clone()),
      PanelHeader(
        title: (strings) => strings.playStoreTitle,
        size: Vector2(360, 68),
        position: Vector2(center, 0),
        anchor: Anchor.center,
      ),
      PanelCloseButton(
        position: Vector2(designSize.x - 16, 16),
        anchor: Anchor.center,
        onPressed: close,
      ),
      _note = LocalizedTextBoxComponent(
        selector: (strings) => strings.playStoreNote,
        textRenderer: narrow
            ? TextStyles.enlarged(TextStyles.paragraph, 1.15)
            : TextStyles.paragraph,
        boxConfig: TextBoxConfig(maxWidth: designSize.x - 80),
        align: Anchor.topCenter,
        anchor: Anchor.topCenter,
        position: Vector2(center, 56),
      ),
      _open = GameButton(
        label: (strings) => strings.playStoreOpen,
        size: Vector2(280, 80),
        anchor: Anchor.center,
        onPressed: () {
          launchUrl(Uri.parse(playStoreUrl));
          close();
        },
      ),
    ]);
    _note.size.addListener(_layoutContent);
    _layoutContent();
  }

  void _layoutContent() {
    final center = designSize.x / 2;
    final y = _note.position.y + _note.size.y + 30;
    _open.position = Vector2(center, y + 40);
    final height = y + 80 + 36;
    _background.size = Vector2(designSize.x, height);
    resizePanel(Vector2(designSize.x, height));
  }
}
