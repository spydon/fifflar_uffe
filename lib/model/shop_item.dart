import 'package:fifflar_uffe/services/strings.dart';

class ShopItemDef {
  const ShopItemDef({
    required this.id,
    required this.iconPath,
    required this.name,
    required this.basePrice,
    required this.incomePerSecond,
    this.growth = 1.15,
  });

  final String id;
  final String iconPath;
  final String Function(Strings strings) name;
  final double basePrice;
  final double incomePerSecond;
  final double growth;
}
