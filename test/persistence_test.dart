import 'package:fifflar_uffe/services/i18n.dart';
import 'package:fifflar_uffe/services/persistence_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('returns defaults when nothing is saved', () async {
    SharedPreferences.setMockInitialValues({});
    final service = await PersistenceService.create();
    final save = service.load();
    expect(save.balance, 0);
    expect(save.owned, isEmpty);
    expect(save.language, AppLanguage.sv);
  });

  test('round trips balance, owned, and language', () async {
    SharedPreferences.setMockInitialValues({});
    final service = await PersistenceService.create();
    await service.saveGame(balance: 123.4, owned: {'lower_taxes': 3});
    await service.saveLanguage(AppLanguage.en);
    final save = service.load();
    expect(save.balance, 123.4);
    expect(save.owned, {'lower_taxes': 3});
    expect(save.language, AppLanguage.en);
  });

  test('falls back to defaults on corrupt save data', () async {
    SharedPreferences.setMockInitialValues({
      'fifflar_uffe.save.v1': 'not json at all',
      'fifflar_uffe.language': 'en',
    });
    final service = await PersistenceService.create();
    final save = service.load();
    expect(save.balance, 0);
    expect(save.owned, isEmpty);
    expect(save.language, AppLanguage.en);
  });
}
