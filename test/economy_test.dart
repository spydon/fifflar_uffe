import 'dart:math';

import 'package:fifflar_uffe/model/economy.dart';
import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cleaner = skillCatalog.first;

  test('click earns the click value', () {
    final economy = Economy();
    economy.earnClick();
    expect(economy.balance, 10);
  });

  test('price scales with growth factor per purchase', () {
    final economy = Economy(balance: 1000000);
    for (var i = 0; i < 5; i++) {
      final expected = (cleaner.basePrice * pow(cleaner.growth, i))
          .ceilToDouble();
      expect(economy.priceOf(cleaner), expected);
      expect(economy.buy(cleaner), isTrue);
    }
    expect(economy.ownedCount(cleaner), 5);
  });

  test('buy deducts the price', () {
    final economy = Economy(balance: 100);
    expect(economy.buy(cleaner), isTrue);
    expect(economy.balance, 100 - cleaner.basePrice);
  });

  test('cannot buy when unaffordable', () {
    final economy = Economy(balance: cleaner.basePrice - 1);
    expect(economy.buy(cleaner), isFalse);
    expect(economy.balance, cleaner.basePrice - 1);
    expect(economy.ownedCount(cleaner), 0);
  });

  test('locked skills cannot be bought until the requirement is owned', () {
    final apartment = skillById('cheat_apartment');
    final economy = Economy(balance: 1000000);
    expect(economy.isUnlocked(cleaner), isTrue);
    expect(economy.isUnlocked(apartment), isFalse);
    expect(economy.buy(apartment), isFalse);
    expect(economy.buy(cleaner), isTrue);
    expect(economy.isUnlocked(apartment), isTrue);
    expect(economy.buy(apartment), isTrue);
  });

  test('every skill except the root has an existing requirement', () {
    for (final skill in skillCatalog) {
      if (skill.requires == null) {
        expect(skill.id, cleaner.id);
      } else {
        expect(skillById(skill.requires!), isNotNull);
      }
    }
  });

  test('income aggregates over owned items', () {
    final economy = Economy(
      owned: {
        skillCatalog[0].id: 2,
        skillCatalog[2].id: 1,
      },
    );
    final expected =
        2 * skillCatalog[0].incomePerSecond + skillCatalog[2].incomePerSecond;
    expect(economy.incomePerSecond, expected);
    economy.tick(2);
    expect(economy.balance, 2 * expected);
  });

  test('total earned accumulates and is not reduced by purchases', () {
    final economy = Economy();
    while (economy.balance < cleaner.basePrice) {
      economy.earnClick();
    }
    economy.tick(4);
    final earned = economy.balance;
    expect(economy.totalEarned, earned);
    expect(economy.buy(cleaner), isTrue);
    expect(economy.totalEarned, earned);
    expect(economy.balance, earned - cleaner.basePrice);
  });

  test('reset clears balance, total earned, and owned items', () {
    final economy = Economy(
      balance: 100,
      totalEarned: 250,
      owned: {cleaner.id: 3},
    );
    economy.reset();
    expect(economy.balance, 0);
    expect(economy.totalEarned, 0);
    expect(economy.owned, isEmpty);
  });

  test('click multiplier scales with owned multiplier skills', () {
    final book = skillById('write_book');
    final economy = Economy(owned: {book.id: 1});
    expect(economy.clickMultiplier, 2);
    expect(economy.incomePerSecond, 0);
    economy.earnClick();
    expect(economy.balance, 20);
  });

  test('deeper multiplier skills give bigger click bonuses', () {
    final economy = Economy(
      owned: {
        'write_book': 2,
        'lower_taxes': 1,
        'break_promise': 1,
        'cut_sick_leave': 1,
      },
    );
    expect(economy.clickMultiplier, 1 + 2 + 2 + 5 + 10);
    economy.earnClick();
    expect(economy.balance, 200);
  });
}
