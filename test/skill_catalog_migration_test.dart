import 'dart:io';

import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:fifflar_uffe/util/snake_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the server side skill catalog matches the game', () {
    final sql = File(
      'supabase/migrations/20260820120000_highscores.sql',
    ).readAsStringSync();
    final insert = RegExp(
      r'insert into public\.skill_catalog\s*\([^)]*\)\s*values\s*(.*?);',
      dotAll: true,
    ).firstMatch(sql);
    expect(insert, isNotNull, reason: 'catalog insert not found');
    final rowPattern = RegExp(
      r"\('(\w+)',\s*([\d.]+),\s*([\d.]+),\s*([\d.]+),\s*(\d+),\s*"
      r"(null|'(\w+)')\)",
    );
    final rows = {
      for (final row in rowPattern.allMatches(insert!.group(1)!))
        row.group(1)!: (
          basePrice: double.parse(row.group(2)!),
          growth: double.parse(row.group(3)!),
          incomePerSecond: double.parse(row.group(4)!),
          clickFactor: int.parse(row.group(5)!),
          requires: row.group(7),
        ),
    };
    expect(rows.length, skillCatalog.length);
    for (final skill in skillCatalog) {
      final row = rows[skill.id.snakeCaseName];
      expect(row, isNotNull, reason: '${skill.id} missing from the migration');
      expect(row!.basePrice, skill.basePrice, reason: '${skill.id} price');
      expect(row.growth, skill.growth, reason: '${skill.id} growth');
      expect(
        row.incomePerSecond,
        skill.incomePerSecond,
        reason: '${skill.id} income',
      );
      expect(row.clickFactor, skill.clickFactor, reason: '${skill.id} factor');
      expect(
        row.requires,
        skill.requires?.snakeCaseName,
        reason: '${skill.id} requirement',
      );
    }
  });
}
