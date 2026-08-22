import 'package:fifflar_uffe/services/highscore_client.dart';

class FakeHighscoreClient implements HighscoreClient {
  bool online = true;
  bool rateLimited = false;
  Leaderboard leaderboard = const Leaderboard();
  final Map<LeaderboardPeriod, Leaderboard> periodLeaderboards = {};
  final List<LeaderboardPeriod> fetchedPeriods = [];
  int runCounter = 0;
  int signIns = 0;
  int serverSeq = 0;
  HighscoreError? reportError;
  HighscoreError? submitError;
  SubmitResult Function(RunSnapshot snapshot)? submitResult;
  final List<({String runId, RunSnapshot snapshot})> reports = [];
  final List<({String runId, String name, RunSnapshot snapshot})> submissions =
      [];
  final List<({String runId, RunSnapshot snapshot})> brokenReports = [];
  int stateRequests = 0;

  void _checkOnline() {
    if (!online) {
      throw const HighscoreException(HighscoreError.network);
    }
  }

  @override
  Future<void> signIn() async {
    _checkOnline();
    signIns++;
  }

  @override
  Future<RunToken> startRun() async {
    _checkOnline();
    if (rateLimited) {
      throw const HighscoreException(HighscoreError.rateLimited);
    }
    runCounter++;
    serverSeq = 0;
    return RunToken(id: 'run-$runCounter', seq: 0);
  }

  @override
  Future<int> reportProgress({
    required String runId,
    required RunSnapshot snapshot,
  }) async {
    _checkOnline();
    final error = reportError;
    if (error != null) {
      reportError = null;
      throw HighscoreException(error, hint: '$serverSeq');
    }
    reports.add((runId: runId, snapshot: snapshot));
    serverSeq = snapshot.seq;
    return snapshot.seq;
  }

  @override
  Future<RunState> runState({required String runId}) async {
    _checkOnline();
    stateRequests++;
    return RunState(
      seq: serverSeq,
      flagged: null,
      submitted: false,
      brokeCapitalism: false,
    );
  }

  @override
  Future<SubmitResult> submitScore({
    required String runId,
    required String name,
    required RunSnapshot snapshot,
  }) async {
    _checkOnline();
    final error = submitError;
    if (error != null) {
      throw HighscoreException(error);
    }
    submissions.add((runId: runId, name: name, snapshot: snapshot));
    serverSeq = snapshot.seq;
    final builder = submitResult;
    if (builder != null) {
      return builder(snapshot);
    }
    return SubmitResult(
      seq: snapshot.seq,
      rank: 1,
      best: snapshot.totalEarned,
      isNewBest: true,
    );
  }

  @override
  Future<int> reportBrokenCapitalism({
    required String runId,
    required RunSnapshot snapshot,
  }) async {
    _checkOnline();
    brokenReports.add((runId: runId, snapshot: snapshot));
    serverSeq = snapshot.seq;
    return snapshot.seq;
  }

  @override
  Future<Leaderboard> fetchLeaderboard({
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
  }) async {
    _checkOnline();
    fetchedPeriods.add(period);
    return periodLeaderboards[period] ?? leaderboard;
  }
}
