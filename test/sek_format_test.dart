import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats zero', () {
    expect(formatSek(0), '0 kr');
  });

  test('groups thousands with non-breaking spaces', () {
    expect(formatSek(1234), '1 234 kr');
  });

  test('floors fractions and groups millions', () {
    expect(formatSek(1234567.9), '1 234 567 kr');
  });

  test('leaves numbers below one thousand ungrouped', () {
    expect(formatSek(999.99), '999 kr');
  });

  test('short format keeps ordinary numbers as they are', () {
    expect(
      formatSekShort(999999999999999),
      '999\u00a0999\u00a0999\u00a0999\u00a0999\u00a0kr',
    );
  });

  test('short format switches to exponent notation at one quadrillion', () {
    expect(formatSekShort(1e15), '1,0e15\u00a0kr');
    expect(formatSekShort(1.26e290), '1,3e290\u00a0kr');
    expect(formatSekShort(9.96e20), '1,0e21\u00a0kr');
  });
}
