const String _nonBreakingSpace = ' ';

String formatSek(double value) {
  final whole = value.floor().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) {
      buffer.write(_nonBreakingSpace);
    }
    buffer.write(whole[i]);
  }
  buffer.write('${_nonBreakingSpace}kr');
  return buffer.toString();
}
