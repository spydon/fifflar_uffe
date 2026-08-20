import 'package:fifflar_uffe/util/non_breaking_numbers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const nbsp = ' ';

  test('binds grouped digits with non-breaking spaces', () {
    expect(
      nonBreakingNumbers('för 694 500 kronor'),
      'för 694${nbsp}500${nbsp}kronor',
    );
    expect(nonBreakingNumbers('1 200 lägenheter'), '1${nbsp}200 lägenheter');
  });

  test('binds numbers to currency and magnitude units', () {
    expect(nonBreakingNumbers('för 300 miljoner'), 'för 300${nbsp}miljoner');
    expect(nonBreakingNumbers('29,7 miljarder'), '29,7${nbsp}miljarder');
    expect(nonBreakingNumbers('1.4 billion'), '1.4${nbsp}billion');
  });

  test('leaves regular words alone', () {
    expect(nonBreakingNumbers('668 taxiresor'), '668 taxiresor');
    expect(nonBreakingNumbers('utan siffror alls'), 'utan siffror alls');
  });
}
