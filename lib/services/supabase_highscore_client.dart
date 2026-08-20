import 'dart:async';

import 'package:fifflar_uffe/services/highscore_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHighscoreClient implements HighscoreClient {
  SupabaseHighscoreClient({
    this.url = 'https://vkpjhhqimxlderiyrlpi.supabase.co',
    this.publishableKey = 'sb_publishable_pvtmfN8xlk2JLZZDHxB6IQ_0tXHmtks',
    this.requestTimeout = const Duration(seconds: 8),
  });

  final String url;
  final String publishableKey;
  final Duration requestTimeout;

  Future<SupabaseClient>? _client;

  Future<SupabaseClient> _ensureClient() {
    final pending = _client ??= _initialize().onError<Object>((error, stack) {
      _client = null;
      throw HighscoreException(HighscoreError.network, cause: error);
    });
    return pending;
  }

  Future<SupabaseClient> _initialize() async {
    final supabase = await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
      authOptions: const FlutterAuthClientOptions(detectSessionInUri: false),
      postgrestOptions: PostgrestClientOptions(requestTimeout: requestTimeout),
    );
    return supabase.client;
  }

  @override
  Future<void> signIn() async {
    final client = await _ensureClient();
    if (client.auth.currentSession != null) {
      return;
    }
    try {
      await client.auth.signInAnonymously();
    } on AuthException catch (exception) {
      throw HighscoreException(
        HighscoreError.notAuthenticated,
        hint: exception.message,
        cause: exception,
      );
    } on Exception catch (exception) {
      throw HighscoreException(HighscoreError.network, cause: exception);
    }
  }

  @override
  Future<RunToken> startRun() async {
    final json = await _call('start_run');
    return RunToken(id: json['run_id'] as String, seq: json['seq'] as int);
  }

  @override
  Future<int> reportProgress({
    required String runId,
    required RunSnapshot snapshot,
  }) async {
    final json = await _call('report_progress', {
      'p_run_id': runId,
      ...snapshot.toParams(),
    });
    return json['seq'] as int;
  }

  @override
  Future<RunState> runState({required String runId}) async {
    return RunState.fromJson(await _call('run_state', {'p_run_id': runId}));
  }

  @override
  Future<SubmitResult> submitScore({
    required String runId,
    required String name,
    required RunSnapshot snapshot,
  }) async {
    final json = await _call('submit_score', {
      'p_run_id': runId,
      'p_name': name,
      ...snapshot.toParams(),
    });
    return SubmitResult.fromJson(json);
  }

  @override
  Future<int> reportBrokenCapitalism({
    required String runId,
    required RunSnapshot snapshot,
  }) async {
    final json = await _call('report_broken_capitalism', {
      'p_run_id': runId,
      ...snapshot.toParams(),
    });
    return json['seq'] as int;
  }

  @override
  Future<Leaderboard> fetchLeaderboard() async {
    return Leaderboard.fromJson(await _call('leaderboard'));
  }

  Future<Map<String, dynamic>> _call(
    String function, [
    Map<String, dynamic>? params,
  ]) async {
    final client = await _ensureClient();
    final Object? result;
    try {
      result = await client.rpc<dynamic>(function, params: params);
    } on PostgrestApiException catch (exception) {
      if (_isAuthFailure(exception)) {
        await _forgetSession(client);
        throw HighscoreException(
          HighscoreError.notAuthenticated,
          hint: exception.message,
          cause: exception,
        );
      }
      throw HighscoreException(
        HighscoreError.fromCode(exception.message),
        hint: exception.hint,
        cause: exception,
      );
    } on AuthException catch (exception) {
      await _forgetSession(client);
      throw HighscoreException(
        HighscoreError.notAuthenticated,
        hint: exception.message,
        cause: exception,
      );
    } on TimeoutException {
      rethrow;
    } on Exception catch (exception) {
      throw HighscoreException(HighscoreError.network, cause: exception);
    }
    if (result is! Map<String, dynamic>) {
      throw HighscoreException(HighscoreError.unknown, hint: '$result');
    }
    if (result['ok'] != true) {
      throw HighscoreException(
        HighscoreError.fromCode(result['error'] as String?),
        hint: result['hint'] as String?,
      );
    }
    return result;
  }

  bool _isAuthFailure(PostgrestApiException exception) {
    final code = exception.errorCode ?? '';
    return exception.statusCode == 401 ||
        exception.statusCode == 403 ||
        code == '42501' ||
        code.startsWith('PGRST30');
  }

  Future<void> _forgetSession(SupabaseClient client) async {
    try {
      await client.auth.signOut();
    } on Exception {
      return;
    }
  }
}
