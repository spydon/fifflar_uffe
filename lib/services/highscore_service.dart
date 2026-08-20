import 'dart:async';

import 'package:fifflar_uffe/services/highscore_client.dart';
import 'package:flutter/foundation.dart';

class HighscoreService {
  HighscoreService({
    this.client,
    this.timeout = const Duration(seconds: 8),
    this.probeInterval = const Duration(seconds: 30),
    this.offlineBackoff = const Duration(minutes: 10),
  });

  final HighscoreClient? client;
  final Duration timeout;
  final Duration probeInterval;
  final Duration offlineBackoff;

  final ValueNotifier<bool> available = ValueNotifier(false);
  Leaderboard? lastLeaderboard;

  Future<void>? _probe;
  DateTime? _lastSuccess;
  DateTime? _offlineUntil;

  bool get isConfigured => client != null;

  Future<void> probe({bool force = false}) {
    final running = _probe;
    if (running != null) {
      return running;
    }
    final client = this.client;
    if (client == null) {
      return Future.value();
    }
    final now = DateTime.now();
    final offlineUntil = _offlineUntil;
    if (!force && offlineUntil != null && now.isBefore(offlineUntil)) {
      return Future.value();
    }
    final lastSuccess = _lastSuccess;
    if (!force &&
        available.value &&
        lastSuccess != null &&
        now.difference(lastSuccess) < probeInterval) {
      return Future.value();
    }
    final probe = _runProbe(client).whenComplete(() => _probe = null);
    _probe = probe;
    return probe;
  }

  Future<void> _runProbe(HighscoreClient client) async {
    try {
      await fetchLeaderboard();
    } on HighscoreException {
      return;
    } on TimeoutException {
      return;
    }
  }

  Future<Leaderboard> fetchLeaderboard() => _guard((client) async {
    await client.signIn();
    final leaderboard = await client.fetchLeaderboard();
    lastLeaderboard = leaderboard;
    return leaderboard;
  });

  Future<RunToken> startRun() => _guard((client) async {
    await client.signIn();
    return client.startRun();
  });

  Future<int> reportProgress({
    required String runId,
    required RunSnapshot snapshot,
  }) => _guard(
    (client) => client.reportProgress(runId: runId, snapshot: snapshot),
  );

  Future<RunState> runState({required String runId}) =>
      _guard((client) => client.runState(runId: runId));

  Future<SubmitResult> submitScore({
    required String runId,
    required String name,
    required RunSnapshot snapshot,
  }) => _guard(
    (client) =>
        client.submitScore(runId: runId, name: name, snapshot: snapshot),
  );

  Future<int> reportBrokenCapitalism({
    required String runId,
    required RunSnapshot snapshot,
  }) => _guard(
    (client) => client.reportBrokenCapitalism(runId: runId, snapshot: snapshot),
  );

  Future<T> _guard<T>(Future<T> Function(HighscoreClient client) call) async {
    final client = this.client;
    if (client == null) {
      throw const HighscoreException(HighscoreError.network);
    }
    try {
      final result = await call(client).timeout(timeout);
      _lastSuccess = DateTime.now();
      _offlineUntil = null;
      available.value = true;
      return result;
    } on TimeoutException {
      available.value = false;
      rethrow;
    } on HighscoreException catch (exception) {
      if (exception.error.isConnectivity) {
        available.value = false;
      } else if (exception.error == HighscoreError.rateLimited) {
        available.value = false;
        _offlineUntil = DateTime.now().add(offlineBackoff);
      }
      rethrow;
    }
  }
}
