import 'package:fifflar_uffe/model/skill_id.dart';
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
    this.clickFactor = 1,
    this.growth = 1.15,
  });

  final SkillId id;
  final String iconPath;
  final String Function(Strings strings) name;
  final List<String> Function(Strings strings) quip;
  final String Function(Strings strings) explanation;
  final String source;
  final String sourceUrl;
  final double basePrice;
  final int tier;
  final int branch;
  final SkillId? requires;
  final double incomePerSecond;
  final int clickFactor;
  final double growth;

  bool get isClickMultiplier => clickFactor > 1;
}
