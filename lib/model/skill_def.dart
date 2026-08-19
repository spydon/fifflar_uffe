import 'package:fifflar_uffe/services/strings.dart';

class SkillDef {
  const SkillDef({
    required this.id,
    required this.iconPath,
    required this.name,
    required this.quip,
    required this.explanation,
    required this.source,
    required this.sourceUrl,
    required this.basePrice,
    required this.tier,
    required this.branch,
    this.requires,
    this.incomePerSecond = 0,
    this.clickBonus = 0,
    this.growth = 1.15,
  });

  final String id;
  final String iconPath;
  final String Function(Strings strings) name;
  final String Function(Strings strings) quip;
  final String Function(Strings strings) explanation;
  final String source;
  final String sourceUrl;
  final double basePrice;
  final int tier;
  final int branch;
  final String? requires;
  final double incomePerSecond;
  final int clickBonus;
  final double growth;

  bool get isClickMultiplier => clickBonus > 0;
}
