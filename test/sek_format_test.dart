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
}
