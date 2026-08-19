import 'package:fifflar_uffe/components/floating_text_component.dart';
import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/shop_catalog.dart';
import 'package:fifflar_uffe/model/shop_item.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/localized_text_component.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_close_button.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class ShopRoute extends Route {
  ShopRoute() : super(ShopPage.new, transparent: true, maintainState: false);
}

class ShopPage extends ModalPage {
  ShopPage() : super(designSize: Vector2(860, 800));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    panel.addAll([
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.panelShop)),
        size: designSize,
      ),
      PanelHeader(
        title: (strings) => strings.shopTitle,
        size: Vector2(400, 70),
        position: Vector2(designSize.x / 2, 0),
        anchor: Anchor.center,
      ),
      PanelCloseButton(
        position: Vector2(designSize.x - 16, 16),
        anchor: Anchor.center,
        onPressed: close,
      ),
      ColumnComponent(
        gap: 12,
        position: Vector2(70, 84),
        children: [for (final item in shopCatalog) ShopItemRow(item: item)],
      ),
    ]);
  }
}

class ShopItemRow extends PositionComponent
    with HasGameReference<FifflarUffeGame> {
  ShopItemRow({required this.item}) : super(size: Vector2(720, 88));

  final ShopItemDef item;

  late final TextComponent _info;
  late final GameButton _buyButton;

  @override
  Future<void> onLoad() async {
    _info = TextComponent(
      textRenderer: TextStyles.info,
      anchor: Anchor.centerLeft,
      position: Vector2(100, 60),
    );
    _buyButton = GameButton(
      label: (strings) => strings.buy,
      size: Vector2(150, 66),
      position: Vector2(size.x, size.y / 2),
      anchor: Anchor.centerRight,
      onPressed: _buy,
    );
    addAll([
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(AssetPaths.itemSlot)),
        size: Vector2(82, 88),
      ),
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(item.iconPath)),
        size: Vector2.all(48),
        anchor: Anchor.center,
        position: Vector2(41, 44),
      ),
      LocalizedTextComponent(
        selector: item.name,
        textRenderer: TextStyles.body,
        anchor: Anchor.centerLeft,
        position: Vector2(100, 24),
      ),
      _info,
      _buyButton,
    ]);
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
    if (game.buyItem(item) && item.isClickMultiplier) {
      add(
        FloatingTextComponent(
          text: 'x${game.economy.clickMultiplier}',
          position: Vector2(size.x - 75, 10),
        ),
      );
    }
  }

  void _refresh() {
    final strings = game.i18n.strings;
    final economy = game.economy;
    final effect = item.isClickMultiplier
        ? 'x${economy.ownedCount(item) + 1}'
        : '+${item.incomePerSecond} ${strings.perSecond}';
    _info.text =
        '${formatSek(economy.priceOf(item))}'
        ' | ${strings.owned}: ${economy.ownedCount(item)}'
        ' | $effect';
    _buyButton.isDisabled = !economy.canAfford(item);
  }
}
