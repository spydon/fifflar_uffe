import 'dart:ui';

import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:fifflar_uffe/model/skill_def.dart';
import 'package:fifflar_uffe/routes/skill_detail_route.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_close_button.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class SkillTreeRoute extends Route {
  SkillTreeRoute()
    : super(SkillTreePage.new, transparent: true, maintainState: false);
}

class SkillTreePage extends ModalPage {
  SkillTreePage() : super(designSize: Vector2(560, 880));

  static Vector2 nodePosition(SkillDef skill) =>
      Vector2(100.0 + skill.branch * 180.0, 118.0 + skill.tier * 160.0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    panel.addAll([
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.panelShop)),
        size: designSize,
      ),
      _SkillTreeEdges(),
      PanelHeader(
        title: (strings) => strings.skillTreeTitle,
        size: Vector2(380, 66),
        position: Vector2(designSize.x / 2, 0),
        anchor: Anchor.center,
      ),
      PanelCloseButton(
        position: Vector2(designSize.x - 16, 16),
        anchor: Anchor.center,
        onPressed: close,
      ),
      for (final skill in skillCatalog)
        SkillNodeComponent(skill: skill, position: nodePosition(skill)),
    ]);
  }
}

class _SkillTreeEdges extends PositionComponent {
  _SkillTreeEdges() : super(priority: 1);

  static final Paint _paint = Paint()
    ..color = const Color(0xB38A7156)
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    for (final skill in skillCatalog) {
      final requirement = skill.requires;
      if (requirement == null) {
        continue;
      }
      final parent = SkillTreePage.nodePosition(skillById(requirement));
      final child = SkillTreePage.nodePosition(skill);
      final start = Offset(parent.x, parent.y + 66);
      final end = Offset(child.x, child.y - 62);
      if (parent.x == child.x) {
        canvas.drawLine(start, end, _paint);
        continue;
      }
      final midY = (start.dy + end.dy) / 2;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(start.dx, midY)
        ..lineTo(end.dx, midY)
        ..lineTo(end.dx, end.dy);
      canvas.drawPath(path, _paint);
    }
  }
}

class SkillNodeComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FifflarUffeGame> {
  SkillNodeComponent({required this.skill, super.position})
    : super(size: Vector2(110, 124), anchor: Anchor.center, priority: 2);

  final SkillDef skill;

  late final SpriteComponent _icon;
  late final SpriteComponent _lock;
  late final TextComponent _count;
  late final TextComponent _price;

  @override
  Future<void> onLoad() async {
    addAll([
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.itemSlot)),
        size: Vector2(96, 104),
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2, 0),
      ),
      _icon = SpriteComponent(
        sprite: Sprite(game.images.fromCache(skill.iconPath)),
        size: Vector2.all(54),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, 50),
      ),
      _lock = SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.iconLock)),
        size: Vector2.all(36),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, 50),
      ),
      _count = TextComponent(
        textRenderer: TextStyles.tileCount,
        anchor: Anchor.topRight,
        position: Vector2(size.x / 2 + 40, 4),
      ),
      _price = TextComponent(
        textRenderer: TextStyles.treePrice,
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2, 106),
      ),
    ]);
  }

  @override
  void onMount() {
    super.onMount();
    _refresh();
    game.economy.addListener(_refresh);
  }

  @override
  void onRemove() {
    game.economy.removeListener(_refresh);
    super.onRemove();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.router.pushRoute(SkillDetailRoute(skill: skill));
  }

  void _refresh() {
    final economy = game.economy;
    final narrow = game.size.x < 560;
    final unlocked = economy.isUnlocked(skill);
    _lock.opacity = unlocked ? 0 : 1;
    _icon.opacity = unlocked ? 1 : 0.3;
    _count.text = economy.ownedCount(skill) > 0
        ? '${economy.ownedCount(skill)}'
        : '';
    _price.text = unlocked ? formatSek(economy.priceOf(skill)) : '';
    final priceStyle = economy.canAfford(skill)
        ? TextStyles.treePrice
        : TextStyles.treePriceDisabled;
    _price.textRenderer = narrow
        ? TextStyles.enlarged(priceStyle, 1.25)
        : priceStyle;
  }
}
