import 'dart:math';

import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:fifflar_uffe/model/skill_def.dart';
import 'package:fifflar_uffe/model/skill_id.dart';
import 'package:flutter/foundation.dart';

class Economy extends ChangeNotifier {
  Economy({this._balance = 0, this._totalEarned = 0, Map<SkillId, int>? owned})
    : _owned = Map.of(owned ?? {});

  double _balance;
  double _totalEarned;
  final Map<SkillId, int> _owned;
  double baseClickValue = 10;

  double get balance => _balance;

  double get totalEarned => _totalEarned;

  int get clickMultiplier => skillCatalog.fold(
    1,
    (multiplier, skill) => multiplier + skill.clickBonus * ownedCount(skill),
  );

  double get clickValue => baseClickValue * clickMultiplier;

  Map<SkillId, int> get owned => Map.unmodifiable(_owned);

  int ownedCount(SkillDef skill) => _owned[skill.id] ?? 0;

  bool isUnlocked(SkillDef skill) {
    final requirement = skill.requires;
    return requirement == null || (_owned[requirement] ?? 0) > 0;
  }

  double get incomePerSecond => skillCatalog.fold(
    0,
    (sum, skill) => sum + skill.incomePerSecond * ownedCount(skill),
  );

  double priceOf(SkillDef skill) {
    return (skill.basePrice * pow(skill.growth, ownedCount(skill)))
        .ceilToDouble();
  }

  bool canAfford(SkillDef skill) => _balance >= priceOf(skill);

  void earnClick() {
    _balance += clickValue;
    _totalEarned += clickValue;
    notifyListeners();
  }

  void tick(double seconds) {
    final income = incomePerSecond * seconds;
    if (income > 0) {
      _balance += income;
      _totalEarned += income;
      notifyListeners();
    }
  }

  void reset() {
    _balance = 0;
    _totalEarned = 0;
    _owned.clear();
    notifyListeners();
  }

  bool buy(SkillDef skill) {
    if (!isUnlocked(skill) || !canAfford(skill)) {
      return false;
    }
    _balance -= priceOf(skill);
    _owned[skill.id] = ownedCount(skill) + 1;
    notifyListeners();
    return true;
  }
}
