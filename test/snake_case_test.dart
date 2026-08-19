import 'package:fifflar_uffe/model/skill_id.dart';
import 'package:fifflar_uffe/util/snake_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converts camel case to snake case', () {
    expect('hireCleaner'.toSnakeCase, 'hire_cleaner');
    expect('sellPublicHousing'.toSnakeCase, 'sell_public_housing');
    expect('single'.toSnakeCase, 'single');
  });

  test('enum names convert to stable storage keys', () {
    expect(SkillId.hireCleaner.snakeCaseName, 'hire_cleaner');
    expect(SkillId.sellPublicHousing.snakeCaseName, 'sell_public_housing');
  });

  test('storage keys round trip back to skill ids', () {
    for (final id in SkillId.values) {
      expect(SkillId.fromSnakeCase(id.snakeCaseName), id);
    }
    expect(SkillId.fromSnakeCase('unknown_skill'), isNull);
  });
}
