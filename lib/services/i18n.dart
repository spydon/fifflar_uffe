import 'package:fifflar_uffe/services/strings.dart';
import 'package:flutter/foundation.dart';

enum AppLanguage {
  sv,
  en;

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.name == code,
      orElse: () => AppLanguage.sv,
    );
  }
}

class I18n {
  I18n({AppLanguage initialLanguage = AppLanguage.sv})
    : language = ValueNotifier(initialLanguage);

  final ValueNotifier<AppLanguage> language;

  Strings get strings => switch (language.value) {
    AppLanguage.sv => const SvStrings(),
    AppLanguage.en => const EnStrings(),
  };
}
