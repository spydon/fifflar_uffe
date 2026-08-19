extension SnakeCaseString on String {
  String get toSnakeCase => replaceAllMapped(
    RegExp('[A-Z]'),
    (match) => '_${match[0]!.toLowerCase()}',
  );
}

extension SnakeCaseEnum on Enum {
  String get snakeCaseName => name.toSnakeCase;
}
