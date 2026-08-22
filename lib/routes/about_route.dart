import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/ui/localized_link_component.dart';
import 'package:fifflar_uffe/ui/localized_text_box_component.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_close_button.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class AboutRoute extends Route {
  AboutRoute() : super(AboutPage.new, transparent: true, maintainState: false);
}

class AboutPage extends ModalPage {
  AboutPage() : super(designSize: Vector2(520, 280));

  late final SpriteComponent _background;
  late final LocalizedTextBoxComponent _satire;
  late final LocalizedLinkComponent _references;
  late final LocalizedLinkComponent _imageCredits;
  late final LocalizedTextBoxComponent _openSource;
  late final LocalizedLinkComponent _github;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (isNarrowScreen) {
      resizePanel(Vector2(460, designSize.y));
    }
    final textWidth = designSize.x - 140;
    final left = (designSize.x - textWidth) / 2;
    panel.addAll([
      _background = SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.panelShop)),
        size: designSize.clone(),
      ),
      PanelHeader(
        title: (strings) => strings.about,
        size: Vector2(300, 68),
        position: Vector2(designSize.x / 2, 0),
        anchor: Anchor.center,
      ),
      PanelCloseButton(
        position: Vector2(designSize.x - 16, 16),
        anchor: Anchor.center,
        onPressed: close,
      ),
      _satire = LocalizedTextBoxComponent(
        selector: (strings) => strings.aboutSatire,
        textRenderer: isNarrowScreen
            ? TextStyles.enlarged(TextStyles.paragraph, 1.25)
            : TextStyles.paragraph,
        boxConfig: TextBoxConfig(maxWidth: textWidth),
        position: Vector2(left, 50),
      ),
      _references = LocalizedLinkComponent(
        selector: (strings) => strings.references,
        url: 'references.html',
        textRenderer: isNarrowScreen
            ? TextStyles.enlarged(TextStyles.eventLink, 1.3)
            : TextStyles.eventLink,
        position: Vector2(left + 8, 160),
      ),
      _imageCredits = LocalizedLinkComponent(
        selector: (strings) => strings.aboutAttributions,
        url: 'attributions.html',
        textRenderer: isNarrowScreen
            ? TextStyles.enlarged(TextStyles.eventLink, 1.3)
            : TextStyles.eventLink,
        position: Vector2(left + 8, 198),
      ),
      _openSource = LocalizedTextBoxComponent(
        selector: (strings) => strings.aboutOpenSource,
        textRenderer: isNarrowScreen
            ? TextStyles.enlarged(TextStyles.paragraph, 1.25)
            : TextStyles.paragraph,
        boxConfig: TextBoxConfig(maxWidth: textWidth),
        position: Vector2(left, 240),
      ),
      _github = LocalizedLinkComponent(
        selector: (strings) => strings.aboutGithub,
        url: 'https://github.com/spydon/fifflar_uffe',
        textRenderer: isNarrowScreen
            ? TextStyles.enlarged(TextStyles.eventLink, 1.3)
            : TextStyles.eventLink,
        position: Vector2(left + 8, 330),
      ),
    ]);
    _satire.size.addListener(_layoutContent);
    _openSource.size.addListener(_layoutContent);
    _layoutContent();
  }

  void _layoutContent() {
    final left = (designSize.x - (designSize.x - 140)) / 2;
    final satireBottom = _satire.position.y + _satire.size.y;
    _openSource.position = Vector2(left, satireBottom + 16);
    final openSourceBottom = _openSource.position.y + _openSource.size.y;
    _github.position = Vector2(left + 8, openSourceBottom + 10);
    _references.position = Vector2(left + 8, openSourceBottom + 48);
    _imageCredits.position = Vector2(left + 8, openSourceBottom + 86);
    final height = openSourceBottom + 86 + 26 + 32;
    _background.size = Vector2(designSize.x, height);
    resizePanel(Vector2(designSize.x, height));
  }
}
