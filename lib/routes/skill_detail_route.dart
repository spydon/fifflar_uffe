import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:fifflar_uffe/model/skill_def.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/localized_link_component.dart';
import 'package:fifflar_uffe/ui/localized_text_box_component.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_close_button.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class SkillDetailRoute extends Route {
  SkillDetailRoute({required SkillDef skill})
    : super(() => SkillDetailPage(skill: skill), transparent: true);
}

class SkillDetailPage extends ModalPage {
  SkillDetailPage({required this.skill}) : super(designSize: Vector2(560, 600));

  final SkillDef skill;

  late final PanelComponent _background;
  late final TextComponent _info;
  late final TextComponent _requires;
  late final LocalizedTextBoxComponent _explanation;
  late final LocalizedLinkComponent _sourceLink;
  late final GameButton _buyButton;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    panel.addAll([
      _background = PanelComponent(size: designSize.clone()),
      PanelHeader(
        title: skill.name,
        size: Vector2(450, 62),
        position: Vector2(designSize.x / 2, 0),
        anchor: Anchor.center,
      ),
      PanelCloseButton(
        position: Vector2(designSize.x - 20, 20),
        anchor: Anchor.center,
        onPressed: close,
      ),
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.itemSlot)),
        size: Vector2(86, 94),
        position: Vector2(50, 90),
      ),
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(skill.iconPath)),
        size: Vector2.all(52),
        anchor: Anchor.center,
        position: Vector2(93, 135),
      ),
      _info = TextComponent(
        textRenderer: TextStyles.info,
        position: Vector2(158, 96),
      ),
      _requires = TextComponent(
        textRenderer: TextStyles.info,
        position: Vector2(158, 156),
      ),
      _explanation = LocalizedTextBoxComponent(
        selector: skill.explanation,
        textRenderer: TextStyles.paragraph,
        boxConfig: const TextBoxConfig(maxWidth: 464),
        position: Vector2(48, 204),
      ),
      _sourceLink = LocalizedLinkComponent(
        selector: (strings) => '${strings.sourceLabel}: ${skill.source}',
        url: skill.sourceUrl,
        position: Vector2(56, 428),
      ),
      _buyButton = GameButton(
        label: (strings) => strings.buy,
        size: Vector2(210, 84),
        position: Vector2(designSize.x / 2, 520),
        anchor: Anchor.center,
        onPressed: _buy,
      ),
    ]);
    _explanation.size.addListener(_layoutContent);
    _layoutContent();
  }

  void _layoutContent() {
    final explanationBottom = _explanation.position.y + _explanation.size.y;
    _sourceLink.position = Vector2(56, explanationBottom + 6);
    final buttonCenter = explanationBottom + 6 + 26 + 18 + 42;
    _buyButton.position = Vector2(designSize.x / 2, buttonCenter);
    final height = buttonCenter + 42 + 30;
    _background.size = Vector2(designSize.x, height);
    resizePanel(Vector2(designSize.x, height));
  }

  @override
  void onMount() {
    super.onMount();
    _refresh();
    game.economy.addListener(_refresh);
    game.i18n.language.addListener(_refresh);
  }

  @override
  void onRemove() {
    game.economy.removeListener(_refresh);
    game.i18n.language.removeListener(_refresh);
    super.onRemove();
  }

  void _buy() {
    if (game.buyItem(skill)) {
      close();
    }
  }

  void _refresh() {
    final strings = game.i18n.strings;
    final economy = game.economy;
    final effect = skill.isClickMultiplier
        ? '+${skill.clickBonus}x'
        : '+${skill.incomePerSecond} ${strings.perSecond}';
    _info.text =
        '${formatSek(economy.priceOf(skill))}'
        ' | ${strings.owned}: ${economy.ownedCount(skill)}'
        ' | $effect';
    final unlocked = economy.isUnlocked(skill);
    final requirement = skill.requires;
    _requires.text = unlocked || requirement == null
        ? ''
        : '${strings.requiresLabel}: '
              '${skillById(requirement).name(strings)}';
    _buyButton.isDisabled = !unlocked || !economy.canAfford(skill);
  }
}
