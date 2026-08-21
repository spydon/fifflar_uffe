import 'package:fifflar_uffe/services/i18n.dart';
import 'package:fifflar_uffe/ui/language_flag_button.dart';
import 'package:fifflar_uffe/ui/localized_text_component.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_close_button.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/ui/toggle_button.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class SettingsRoute extends Route {
  SettingsRoute()
    : super(SettingsPage.new, transparent: true, maintainState: false);
}

class SettingsPage extends ModalPage {
  SettingsPage() : super(designSize: Vector2(520, 300));

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
        title: (strings) => strings.settings,
        size: Vector2(360, 68),
        position: Vector2(center, 0),
        anchor: Anchor.center,
      ),
      PanelCloseButton(
        position: Vector2(designSize.x - 16, 16),
        anchor: Anchor.center,
        onPressed: close,
      ),
      LocalizedTextComponent(
        selector: (strings) => strings.language,
        textRenderer: TextStyles.body,
        anchor: Anchor.center,
        position: Vector2(center, 66),
      ),
      LanguageFlagButton(
        language: AppLanguage.sv,
        position: Vector2(center - 66, 132),
        anchor: Anchor.center,
      ),
      LanguageFlagButton(
        language: AppLanguage.en,
        position: Vector2(center + 66, 132),
        anchor: Anchor.center,
      ),
      LocalizedTextComponent(
        selector: (strings) => strings.sound,
        textRenderer: TextStyles.body,
        anchor: Anchor.centerRight,
        position: Vector2(center - 20, 222),
      ),
      ToggleButton(
        value: game.soundEnabled,
        position: Vector2(center + 40, 222),
        anchor: Anchor.center,
      ),
    ]);
  }
}
