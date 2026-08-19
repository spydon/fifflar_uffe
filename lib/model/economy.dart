import 'dart:math';

import 'package:fifflar_uffe/model/shop_catalog.dart';
import 'package:fifflar_uffe/model/shop_item.dart';
import 'package:flutter/foundation.dart';

class Economy extends ChangeNotifier {
  Economy({this._balance = 0, Map<String, int>? owned})
    : _owned = Map.of(owned ?? {});

  double _balance;
  final Map<String, int> _owned;
  double baseClickValue = 1;

  double get balance => _balance;

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
    notifyListeners();
  }

  void tick(double seconds) {
    final income = incomePerSecond * seconds;
    if (income > 0) {
      _balance += income;
      notifyListeners();
    }
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
