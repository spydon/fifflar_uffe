import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/model/shop_item.dart';

final List<ShopItemDef> shopCatalog = [
  ShopItemDef(
    id: 'cheat_apartment',
    iconPath: AssetPaths.iconHouse,
    name: (strings) => strings.itemCheatApartment,
    basePrice: 25,
    incomePerSecond: 0.5,
  ),
  ShopItemDef(
    id: 'lower_taxes',
    iconPath: AssetPaths.iconStorefront,
    name: (strings) => strings.itemLowerTaxes,
    basePrice: 150,
    incomePerSecond: 2,
  ),
  ShopItemDef(
    id: 'privatize_schools',
    iconPath: AssetPaths.iconBook,
    name: (strings) => strings.itemPrivatizeSchools,
    basePrice: 1000,
    incomePerSecond: 10,
  ),
  ShopItemDef(
    id: 'privatize_hospitals',
    iconPath: AssetPaths.iconPotion,
    name: (strings) => strings.itemPrivatizeHospitals,
    basePrice: 6000,
    incomePerSecond: 45,
  ),
];
