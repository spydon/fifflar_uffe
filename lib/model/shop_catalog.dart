import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/model/shop_item.dart';

final List<ShopItemDef> shopCatalog = [
  ShopItemDef(
    id: 'hire_cleaner',
    iconPath: AssetPaths.iconPeople,
    name: (strings) => strings.itemHireCleaner,
    quip: (strings) => strings.quipHireCleaner,
    basePrice: 10,
    incomePerSecond: 0.2,
  ),
  ShopItemDef(
    id: 'cheat_apartment',
    iconPath: AssetPaths.iconHouse,
    name: (strings) => strings.itemCheatApartment,
    quip: (strings) => strings.quipCheatApartment,
    basePrice: 25,
    incomePerSecond: 0.5,
  ),
  ShopItemDef(
    id: 'lower_taxes',
    iconPath: AssetPaths.iconStorefront,
    name: (strings) => strings.itemLowerTaxes,
    quip: (strings) => strings.quipLowerTaxes,
    basePrice: 150,
    isClickMultiplier: true,
  ),
  ShopItemDef(
    id: 'privatize_schools',
    iconPath: AssetPaths.iconBook,
    name: (strings) => strings.itemPrivatizeSchools,
    quip: (strings) => strings.quipPrivatizeSchools,
    basePrice: 1000,
    incomePerSecond: 10,
  ),
  ShopItemDef(
    id: 'privatize_hospitals',
    iconPath: AssetPaths.iconPotion,
    name: (strings) => strings.itemPrivatizeHospitals,
    quip: (strings) => strings.quipPrivatizeHospitals,
    basePrice: 6000,
    incomePerSecond: 45,
  ),
  ShopItemDef(
    id: 'sell_preschools',
    iconPath: AssetPaths.iconBrokenHeart,
    name: (strings) => strings.itemSellPreschools,
    quip: (strings) => strings.quipSellPreschools,
    basePrice: 35000,
    incomePerSecond: 220,
  ),
  ShopItemDef(
    id: 'sell_public_housing',
    iconPath: AssetPaths.iconEnvelope,
    name: (strings) => strings.itemSellPublicHousing,
    quip: (strings) => strings.quipSellPublicHousing,
    basePrice: 200000,
    incomePerSecond: 1100,
  ),
];
