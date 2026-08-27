import 'dart:convert';

import 'package:fifflar_uffe/model/skill_id.dart';
import 'package:fifflar_uffe/services/i18n.dart';
import 'package:fifflar_uffe/util/snake_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveData {
  const SaveData({
    this.balance = 0,
    this.totalEarned = 0,
    this.elapsedDays = 0,
    this.highScore = 0,
    this.continued = false,
    this.owned = const {},
    this.language = AppLanguage.sv,
    this.runId,
    this.runSeq = 0,
    this.runFlagged = false,
    this.highscoreName,
    this.highscoreSubmitted = false,
    this.highscoreRank,
    this.capitalismReported = false,
    this.soundEnabled = true,
  });

  final double balance;
  final double totalEarned;
  final double elapsedDays;
  final double highScore;
  final bool continued;
  final Map<SkillId, int> owned;
  final AppLanguage language;
  final String? runId;
  final int runSeq;
  final bool runFlagged;
  final String? highscoreName;
  final bool highscoreSubmitted;
  final int? highscoreRank;
  final bool capitalismReported;
  final bool soundEnabled;
}

class PersistenceService {
  PersistenceService(this._preferences);

  static const _saveKey = 'fifflar_uffe.save.v1';
  static const _languageKey = 'fifflar_uffe.language';
  static const _soundKey = 'fifflar_uffe.sound_enabled';

  final SharedPreferences _preferences;

  static Future<PersistenceService> create() async {
    return PersistenceService(await SharedPreferences.getInstance());
  }

  SaveData load() {
    final language = AppLanguage.fromCode(_preferences.getString(_languageKey));
    final soundEnabled = _preferences.getBool(_soundKey) ?? true;
    final raw = _preferences.getString(_saveKey);
    if (raw == null) {
      return SaveData(
        language: language,
        soundEnabled: soundEnabled,
      );
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final ownedJson = json['owned'] as Map<String, dynamic>? ?? {};
      final owned = <SkillId, int>{};
      for (final entry in ownedJson.entries) {
        final id = SkillId.fromSnakeCase(entry.key);
        if (id != null) {
          owned[id] = entry.value as int;
        }
      }
      return SaveData(
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0,
        elapsedDays: (json['elapsedDays'] as num?)?.toDouble() ?? 0,
        highScore: (json['highScore'] as num?)?.toDouble() ?? 0,
        continued: json['continued'] as bool? ?? false,
        owned: owned,
        language: language,
        runId: json['runId'] as String?,
        runSeq: json['runSeq'] as int? ?? 0,
        runFlagged: json['runFlagged'] as bool? ?? false,
        highscoreName: json['highscoreName'] as String?,
        highscoreSubmitted: json['highscoreSubmitted'] as bool? ?? false,
        highscoreRank: json['highscoreRank'] as int?,
        capitalismReported: json['capitalismReported'] as bool? ?? false,
        soundEnabled: soundEnabled,
      );
    } on FormatException {
      return SaveData(
        language: language,
        soundEnabled: soundEnabled,
      );
    } on TypeError {
      return SaveData(
        language: language,
        soundEnabled: soundEnabled,
      );
    }
  }

  Future<void> saveGame({
    required double balance,
    required double totalEarned,
    required double elapsedDays,
    required double highScore,
    required bool continued,
    required Map<SkillId, int> owned,
    String? runId,
    int runSeq = 0,
    bool runFlagged = false,
    String? highscoreName,
    bool highscoreSubmitted = false,
    int? highscoreRank,
    bool capitalismReported = false,
  }) async {
    await _preferences.setString(
      _saveKey,
      jsonEncode({
        'balance': balance,
        'totalEarned': totalEarned,
        'elapsedDays': elapsedDays,
        'highScore': highScore,
        'continued': continued,
        'owned': owned.map(
          (id, count) => MapEntry(id.snakeCaseName, count),
        ),
        'runId': runId,
        'runSeq': runSeq,
        'runFlagged': runFlagged,
        'highscoreName': highscoreName,
        'highscoreSubmitted': highscoreSubmitted,
        'highscoreRank': highscoreRank,
        'capitalismReported': capitalismReported,
        'savedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> saveLanguage(AppLanguage language) async {
    await _preferences.setString(_languageKey, language.name);
  }

  Future<void> saveSoundEnabled({required bool enabled}) async {
    await _preferences.setBool(_soundKey, enabled);
  }
}
