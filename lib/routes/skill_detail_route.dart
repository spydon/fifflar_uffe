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

  static const double _labelX = 158;
  static const double _valueX = 272;

  late final PanelComponent _background;
  late final List<TextComponent> _labels;
  late final List<TextComponent> _values;
  late final LocalizedTextBoxComponent _explanation;
  late final LocalizedLinkComponent _sourceLink;
  late final GameButton _buyButton;
  late final TextPaint _valueStyle;
  late final TextPaint _valueMutedStyle;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final narrow = isNarrowScreen;
    if (narrow) {
      resizePanel(Vector2(460, designSize.y));
    }
    final labelStyle = narrow
        ? TextStyles.enlarged(TextStyles.statLabel, 1.2)
        : TextStyles.statLabel;
    _valueStyle = narrow
        ? TextStyles.enlarged(TextStyles.statValue, 1.2)
        : TextStyles.statValue;
    _valueMutedStyle = narrow
        ? TextStyles.enlarged(TextStyles.statValueMuted, 1.2)
        : TextStyles.statValueMuted;
    final valueX = narrow ? 230.0 : _valueX;
    final labelPositions = [
      Vector2(_labelX, 58),
      Vector2(_labelX, narrow ? 92 : 88),
      Vector2(_labelX, narrow ? 126 : 118),
      if (narrow) Vector2(48, 164) else Vector2(_labelX, 148),
    ];
    final valuePositions = [
      Vector2(valueX, 58),
      Vector2(valueX, narrow ? 92 : 88),
      Vector2(valueX, narrow ? 126 : 118),
      if (narrow) Vector2(146, 164) else Vector2(_valueX, 148),
    ];
    _labels = [
      for (final position in labelPositions)
        TextComponent(textRenderer: labelStyle, position: position),
    ];
    _values = [
      for (final position in valuePositions)
        TextComponent(textRenderer: _valueStyle, position: position),
    ];
    panel.addAll([
      _background = PanelComponent(size: designSize.clone()),
      PanelHeader(
        title: skill.name,
        size: Vector2(isNarrowScreen ? 380 : 450, 62),
        position: Vector2(designSize.x / 2, 0),
        anchor: Anchor.center,
      ),
      PanelCloseButton(
        position: Vector2(designSize.x - 20, 20),
        anchor: Anchor.center,
        onPressed: close,
      ),
      SpriteComponent(
        sprite: Sprite(gameRef.images.fromCache(AssetPaths.itemSlot)),
        size: Vector2(86, 94),
        position: Vector2(50, 56),
      ),
      SpriteComponent(
        sprite: Sprite(gameRef.images.fromCache(skill.iconPath)),
        size: Vector2.all(66),
        anchor: Anchor.center,
        position: Vector2(93, 103),
      ),
      ..._labels,
      ..._values,
      _explanation = LocalizedTextBoxComponent(
        selector: skill.explanation,
        textRenderer: narrow
            ? TextStyles.enlarged(TextStyles.paragraph, 1.25)
            : TextStyles.paragraph,
        boxConfig: TextBoxConfig(maxWidth: designSize.x - 96),
        position: Vector2(48, narrow ? 204 : 172),
      ),
      _sourceLink = LocalizedLinkComponent(
        selector: (strings) => '${strings.sourceLabel}: ${skill.source}',
        url: skill.sourceUrl,
        textRenderer: narrow
            ? TextStyles.enlarged(TextStyles.eventLink, 1.3)
            : TextStyles.eventLink,
        position: Vector2(56, 428),
      ),
      _buyButton = GameButton(
        label: (strings) => strings.buy,
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
    gameRef.economy.addListener(_refresh);
    gameRef.i18n.language.addListener(_refresh);
  }

  @override
  void onRemove() {
    gameRef.economy.removeListener(_refresh);
    gameRef.i18n.language.removeListener(_refresh);
    super.onRemove();
  }

  void _buy() {
    if (gameRef.buyItem(skill)) {
      close();
    }
  }

  void _refresh() {
    final strings = gameRef.i18n.strings;
    final economy = gameRef.economy;
    final unlocked = economy.isUnlocked(skill);
    final requirement = skill.requires;
    final effect = skill.isClickMultiplier
        ? 'x${skill.clickFactor} ${strings.perClick}'
        : '+${formatSek(skill.incomePerSecond)}/s';
    _labels[0].text = strings.priceLabel;
    _values[0].text = formatSek(economy.priceOf(skill));
    _values[0].textRenderer = economy.canAfford(skill)
        ? _valueStyle
        : _valueMutedStyle;
    _labels[1].text = strings.owned;
    _values[1].text = '${economy.ownedCount(skill)}';
    _labels[2].text = strings.givesLabel;
    _values[2].text = effect;
    if (unlocked || requirement == null) {
      _labels[3].text = '';
      _values[3].text = '';
    } else {
      _labels[3].text = strings.requiresLabel;
      _values[3].text = skillById(requirement).name(strings);
    }
    _buyButton.isDisabled = !unlocked || !economy.canAfford(skill);
  }
}
