import 'dart:math';

import 'package:fifflar_uffe/model/shop_catalog.dart';
import 'package:fifflar_uffe/model/shop_item.dart';
import 'package:flutter/foundation.dart';

class Economy extends ChangeNotifier {
  Economy({this._balance = 0, this._totalEarned = 0, Map<String, int>? owned})
    : _owned = Map.of(owned ?? {});

  double _balance;
  double _totalEarned;
  final Map<String, int> _owned;
  double baseClickValue = 1;

  double get balance => _balance;

  double get totalEarned => _totalEarned;

  int get clickMultiplier => shopCatalog
      .where((item) => item.isClickMultiplier)
      .fold(1, (multiplier, item) => multiplier + ownedCount(item));

  double get clickValue => baseClickValue * clickMultiplier;

  Map<String, int> get owned => Map.unmodifiable(_owned);

  int ownedCount(ShopItemDef item) => _owned[item.id] ?? 0;

  double get incomePerSecond => shopCatalog.fold(
    0,
    (sum, item) => sum + item.incomePerSecond * ownedCount(item),
  );

  double priceOf(ShopItemDef item) {
    return (item.basePrice * pow(item.growth, ownedCount(item))).ceilToDouble();
  }

  bool canAfford(ShopItemDef item) => _balance >= priceOf(item);

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

  bool buy(ShopItemDef item) {
    if (!canAfford(item)) {
      return false;
    }
    _balance -= priceOf(item);
    _owned[item.id] = ownedCount(item) + 1;
    notifyListeners();
    return true;
  }
}
