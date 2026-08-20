import 'dart:math';

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

String formatSekShort(double value) {
  if (value < 1e15) {
    return formatSek(value);
  }
  var exponent = (log(value) / ln10).floor();
  var mantissa = value / pow(10.0, exponent);
  if (mantissa >= 10) {
    mantissa /= 10;
    exponent++;
  }
  var digits = mantissa.toStringAsFixed(1);
  if (digits == '10.0') {
    digits = '1.0';
    exponent++;
  }
  return '${digits.replaceAll('.', ',')}e$exponent${_nonBreakingSpace}kr';
}
