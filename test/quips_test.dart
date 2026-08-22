import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:fifflar_uffe/services/strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final strings in const [SvStrings(), EnStrings()]) {
    test('every skill has three distinct quips in ${strings.runtimeType}', () {
      for (final skill in skillCatalog) {
        final quips = skill.quip(strings);
        expect(quips, hasLength(3), reason: '${skill.id}');
        expect(quips.toSet(), hasLength(3), reason: '${skill.id}');
        for (final quip in quips) {
          expect(quip.trim(), isNotEmpty, reason: '${skill.id}');
          expect(quip.length, lessThanOrEqualTo(52), reason: quip);
        }
      }
    });
  }
}
