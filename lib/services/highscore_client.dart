enum HighscoreError {
  notAuthenticated('not_authenticated'),
  rateLimited('rate_limited'),
  invalidName('invalid_name'),
  invalidScore('invalid_score'),
  invalidState('invalid_state'),
  unknownRun('unknown_run'),
  badSequence('bad_sequence'),
  flagged('flagged'),
  implausible('implausible'),
  runNotFinished('run_not_finished'),
  runFinished('run_finished'),
  alreadySubmitted('already_submitted'),
  tooEarly('too_early'),
  cooldown('cooldown'),
  network('network'),
  unknown('unknown');

  const HighscoreError(this.code);

  final String code;

  static HighscoreError fromCode(String? code) {
    for (final error in values) {
      if (error.code == code) {
        return error;
      }
    }
    return HighscoreError.unknown;
  }

  bool get isConnectivity =>
      this == HighscoreError.network || this == HighscoreError.notAuthenticated;

  bool get flagsRun =>
      this == HighscoreError.flagged || this == HighscoreError.implausible;
}

class HighscoreException implements Exception {
  const HighscoreException(this.error, {this.hint, this.cause});

  final HighscoreError error;
  final String? hint;
  final Object? cause;

  @override
  String toString() =>
      'HighscoreException(${error.code}'
      '${hint == null ? '' : ', hint: $hint'}'
      '${cause == null ? '' : ', cause: $cause'})';
}

class RunToken {
  const RunToken({required this.id, required this.seq});

  final String id;
  final int seq;
}

class RunSnapshot {
  const RunSnapshot({
    required this.seq,
    required this.elapsedDays,
    required this.totalEarned,
    required this.balance,
    required this.owned,
  });

  final int seq;
  final double elapsedDays;
  final double totalEarned;
  final double balance;
  final Map<String, int> owned;

  RunSnapshot withSeq(int newSeq) => RunSnapshot(
    seq: newSeq,
    elapsedDays: elapsedDays,
    totalEarned: totalEarned,
    balance: balance,
    owned: owned,
  );

  Map<String, dynamic> toParams() => {
    'p_seq': seq,
    'p_elapsed_days': elapsedDays,
    'p_total_earned': totalEarned,
    'p_balance': balance,
    'p_owned': owned,
  };
}

class RunState {
  const RunState({
    required this.seq,
    required this.flagged,
    required this.submitted,
    required this.brokeCapitalism,
  });

  final int seq;
  final String? flagged;
  final bool submitted;
  final bool brokeCapitalism;

  factory RunState.fromJson(Map<String, dynamic> json) => RunState(
    seq: json['seq'] as int,
    flagged: json['flagged'] as String?,
    submitted: json['submitted'] as bool? ?? false,
    brokeCapitalism: json['broke_capitalism'] as bool? ?? false,
  );
}

class HighscoreEntry {
  const HighscoreEntry({
    required this.rank,
    required this.name,
    required this.score,
    required this.isMe,
  });

  final int rank;
  final String name;
  final double score;
  final bool isMe;

  factory HighscoreEntry.fromJson(Map<String, dynamic> json) => HighscoreEntry(
    rank: json['rank'] as int,
    name: json['name'] as String,
    score: (json['score'] as num).toDouble(),
    isMe: json['is_me'] as bool? ?? false,
  );
}

class Leaderboard {
  const Leaderboard({
    this.top = const [],
    this.me,
    this.brokenCapitalismCount = 0,
  });

  final List<HighscoreEntry> top;
  final HighscoreEntry? me;
  final int brokenCapitalismCount;

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    final top = (json['top'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(HighscoreEntry.fromJson)
        .toList();
    final me = json['me'] as Map<String, dynamic>?;
    return Leaderboard(
      top: top,
      me: me == null ? null : HighscoreEntry.fromJson(me),
      brokenCapitalismCount: json['broken_capitalism_count'] as int? ?? 0,
    );
  }
}

class SubmitResult {
  const SubmitResult({
    required this.seq,
    required this.rank,
    required this.best,
    required this.isNewBest,
  });

  final int seq;
  final int rank;
  final double best;
  final bool isNewBest;

  factory SubmitResult.fromJson(Map<String, dynamic> json) => SubmitResult(
    seq: json['seq'] as int,
    rank: json['rank'] as int,
    best: (json['best'] as num).toDouble(),
    isNewBest: json['is_new_best'] as bool? ?? false,
  );
}

abstract interface class HighscoreClient {
  Future<void> signIn();

  Future<RunToken> startRun();

  Future<int> reportProgress({
    required String runId,
    required RunSnapshot snapshot,
  });

  Future<RunState> runState({required String runId});

  Future<SubmitResult> submitScore({
    required String runId,
    required String name,
    required RunSnapshot snapshot,
  });

  Future<int> reportBrokenCapitalism({
    required String runId,
    required RunSnapshot snapshot,
  });

  Future<Leaderboard> fetchLeaderboard();
}
