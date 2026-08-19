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
  AboutPage() : super(designSize: Vector2(700, 280));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    const textWidth = 560.0;
    final left = (designSize.x - textWidth) / 2;
    panel.addAll([
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.panelShop)),
        size: designSize,
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
      LocalizedTextBoxComponent(
        selector: (strings) => strings.aboutSatire,
        textRenderer: TextStyles.paragraph,
        boxConfig: const TextBoxConfig(maxWidth: textWidth),
        position: Vector2(left, 90),
      ),
      LocalizedLinkComponent(
        selector: (strings) => strings.references,
        url: 'references.html',
        position: Vector2(left + 8, 160),
      ),
      LocalizedLinkComponent(
        selector: (strings) => strings.aboutAttributions,
        url: 'attributions.html',
        position: Vector2(left + 8, 198),
      ),
    ]);
  }
}
