import 'dart:math';

import 'package:fifflar_uffe/model/economy.dart';
import 'package:fifflar_uffe/model/shop_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final apartment = shopCatalog.first;

  test('click earns the click value', () {
    final economy = Economy();
    economy.earnClick();
    expect(economy.balance, 1);
  });

  test('price scales with growth factor per purchase', () {
    final economy = Economy(balance: 1000000);
    for (var i = 0; i < 5; i++) {
      final expected = (apartment.basePrice * pow(apartment.growth, i))
          .ceilToDouble();
      expect(economy.priceOf(apartment), expected);
      expect(economy.buy(apartment), isTrue);
    }
    expect(economy.ownedCount(apartment), 5);
  });

  test('buy deducts the price', () {
    final economy = Economy(balance: 100);
    expect(economy.buy(apartment), isTrue);
    expect(economy.balance, 100 - apartment.basePrice);
  });

  test('cannot buy when unaffordable', () {
    final economy = Economy(balance: apartment.basePrice - 1);
    expect(economy.buy(apartment), isFalse);
    expect(economy.balance, apartment.basePrice - 1);
    expect(economy.ownedCount(apartment), 0);
  });

  test('income aggregates over owned items', () {
    final economy = Economy(
      owned: {
        shopCatalog[0].id: 2,
        shopCatalog[2].id: 1,
      },
    );
    final expected =
        2 * shopCatalog[0].incomePerSecond + shopCatalog[2].incomePerSecond;
    expect(economy.incomePerSecond, expected);
    economy.tick(2);
    expect(economy.balance, 2 * expected);
  });

  test('click multiplier scales with owned tax cuts', () {
    final taxCut = shopCatalog.singleWhere((item) => item.isClickMultiplier);
    final economy = Economy(owned: {taxCut.id: 1});
    expect(economy.clickMultiplier, 2);
    expect(economy.incomePerSecond, 0);
    economy.earnClick();
    expect(economy.balance, 2);
  });
}
