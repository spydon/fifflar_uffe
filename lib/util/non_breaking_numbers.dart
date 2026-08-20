final RegExp _digitGroupSpace = RegExp(r'(?<=\d) (?=\d)');
final RegExp _unitSpace = RegExp(
  r'(?<=\d) (?=(kr|kronor|miljoner|miljarder|million|billion)\b)',
);

/// Replaces the spaces inside grouped numbers (and between a number and its
/// currency or magnitude unit) with non-breaking spaces, so text layout
/// never splits a number over two lines.
String nonBreakingNumbers(String text) {
  const nonBreakingSpace = ' ';
  return text
      .replaceAll(_digitGroupSpace, nonBreakingSpace)
      .replaceAll(_unitSpace, nonBreakingSpace);
}
