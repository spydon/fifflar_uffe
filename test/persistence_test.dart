import 'package:fifflar_uffe/model/skill_id.dart';
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
    await service.saveGame(
      balance: 123.4,
      totalEarned: 543.2,
      elapsedDays: 42.5,
      highScore: 999.9,
      continued: true,
      owned: {SkillId.lowerTaxes: 3},
      runId: 'run-1',
      runSeq: 4,
      runFlagged: true,
      highscoreName: 'Uffe',
      highscoreSubmitted: true,
      highscoreRank: 7,
      capitalismReported: true,
    );
    await service.saveLanguage(AppLanguage.en);
    final save = service.load();
    expect(save.balance, 123.4);
    expect(save.totalEarned, 543.2);
    expect(save.elapsedDays, 42.5);
    expect(save.highScore, 999.9);
    expect(save.continued, isTrue);
    expect(save.owned, {SkillId.lowerTaxes: 3});
    expect(save.language, AppLanguage.en);
    expect(save.runId, 'run-1');
    expect(save.runSeq, 4);
    expect(save.runFlagged, isTrue);
    expect(save.highscoreName, 'Uffe');
    expect(save.highscoreSubmitted, isTrue);
    expect(save.highscoreRank, 7);
    expect(save.capitalismReported, isTrue);
  });

  test('older saves without timeline fields load with defaults', () async {
    SharedPreferences.setMockInitialValues({
      'fifflar_uffe.save.v1': '{"balance": 50, "owned": {"lower_taxes": 1}}',
    });
    final service = await PersistenceService.create();
    final save = service.load();
    expect(save.balance, 50);
    expect(save.totalEarned, 0);
    expect(save.elapsedDays, 0);
    expect(save.highScore, 0);
    expect(save.continued, isFalse);
    expect(save.owned, {SkillId.lowerTaxes: 1});
    expect(save.runId, isNull);
    expect(save.runSeq, 0);
    expect(save.runFlagged, isFalse);
    expect(save.highscoreName, isNull);
    expect(save.highscoreSubmitted, isFalse);
    expect(save.highscoreRank, isNull);
    expect(save.capitalismReported, isFalse);
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
