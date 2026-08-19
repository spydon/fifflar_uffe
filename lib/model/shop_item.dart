import 'package:fifflar_uffe/services/strings.dart';

class ShopItemDef {
  const ShopItemDef({
    required this.id,
    required this.iconPath,
    required this.name,
    required this.quip,
    required this.basePrice,
    this.incomePerSecond = 0,
    this.isClickMultiplier = false,
    this.growth = 1.15,
  });

  final String id;
  final String iconPath;
  final String Function(Strings strings) name;
  final String Function(Strings strings) quip;
  final double basePrice;
  final double incomePerSecond;
  final bool isClickMultiplier;
  final double growth;
}
