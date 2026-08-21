import 'dart:convert';

import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/timeline.dart';
import 'package:fifflar_uffe/routes/game_over_route.dart';
import 'package:fifflar_uffe/routes/highscore_route.dart';
import 'package:fifflar_uffe/routes/main_menu_route.dart';
import 'package:fifflar_uffe/services/highscore_client.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/name_input_component.dart';
import 'package:fifflar_uffe/ui/send_button.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_highscore_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'fifflar_uffe.menu_seen': true});
  });

  Future<void> settle(FifflarUffeGame game) async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
      game.update(0);
      await game.ready();
    }
  }

  Future<void> play(FifflarUffeGame game, int seconds) async {
    for (var i = 0; i < seconds; i++) {
      game.update(1);
    }
    await settle(game);
  }

  Map<String, dynamic> finishedSave({String? runId}) => {
    'balance': 10.0,
    'totalEarned': 25.0,
    'elapsedDays': Timeline.totalDays - 0.5,
    'owned': {'hire_cleaner': 1},
    'runId': runId,
    'runSeq': 3,
    'savedAt': '2026-08-19T00:00:00.000',
  };

  Iterable<GameButton> menuButtons(FifflarUffeGame game) => game
      .router
      .currentRoute
      .children
      .whereType<MainMenuPage>()
      .single
      .panel
      .children
      .whereType<GameButton>();

  GameOverPage gameOverPage(FifflarUffeGame game) =>
      game.router.currentRoute.children.whereType<GameOverPage>().single;

  void pressSubmit(FifflarUffeGame game, GameOverPage page) {
    page.panel.children.whereType<SendButton>().single.onPressed!();
  }

  Future<GameOverPage> reachGameOver(FifflarUffeGame game) async {
    await settle(game);
    game.update(1);
    await settle(game);
    expect(game.router.currentRoute, game.router.routes['gameOver']);
    return gameOverPage(game);
  }

  testWithGame<FifflarUffeGame>(
    'without a client the highscore features stay hidden',
    FifflarUffeGame.new,
    (game) async {
      await settle(game);
      expect(game.highscore.available.value, isFalse);
      expect(game.runId, isNull);
      game.router.pushNamed('mainMenu');
      await settle(game);
      expect(menuButtons(game), hasLength(3));
    },
  );

  group('with a reachable backend', () {
    late FakeHighscoreClient client;

    setUp(() {
      client = FakeHighscoreClient()
        ..leaderboard = const Leaderboard(
          top: [
            HighscoreEntry(rank: 1, name: 'Magda', score: 5000, isMe: false),
            HighscoreEntry(rank: 2, name: 'Uffe', score: 25, isMe: true),
          ],
          me: HighscoreEntry(rank: 2, name: 'Uffe', score: 25, isMe: true),
          brokenCapitalismCount: 3,
          gamesPlayed: 42,
        );
    });

    testWithGame<FifflarUffeGame>(
      'a fresh game signs in, gets a run token and shows the highscores',
      () => FifflarUffeGame(highscoreClient: client),
      (game) async {
        await settle(game);
        expect(game.highscore.available.value, isTrue);
        expect(client.signIns, greaterThanOrEqualTo(1));
        expect(game.runId, 'run-1');
        expect(game.persistence.load().runId, 'run-1');
        game.router.pushNamed('mainMenu');
        await settle(game);
        expect(menuButtons(game), hasLength(4));
        game.router.pushNamed('highscore');
        await settle(game);
        final page = game.router.currentRoute.children
            .whereType<HighscorePage>()
            .single;
        final texts = page.panel.children
            .whereType<TextComponent>()
            .map((component) => component.text)
            .toList();
        expect(texts, contains('Magda'));
        expect(texts, contains('5\u00a0000\u00a0kr'));
        expect(texts, contains('Ditt bästa: 25\u00a0kr (plats 2)'));
        expect(texts, contains('3 personer har haft sönder kapitalismen'));
        expect(texts, contains('42 omgångar har spelats totalt'));
      },
    );

    testWithGame<FifflarUffeGame>(
      'a run that is already underway gets no token',
      () {
        SharedPreferences.setMockInitialValues({
          'fifflar_uffe.menu_seen': true,
          'fifflar_uffe.save.v1': jsonEncode({
            'balance': 500.0,
            'totalEarned': 500.0,
            'elapsedDays': 2000.0,
            'owned': <String, int>{},
          }),
        });
        return FifflarUffeGame(highscoreClient: client);
      },
      (game) async {
        await settle(game);
        expect(game.highscore.available.value, isTrue);
        expect(game.runId, isNull);
        expect(client.runCounter, 0);
      },
    );

    testWithGame<FifflarUffeGame>(
      'progress is reported while playing and not while paused',
      () => FifflarUffeGame(highscoreClient: client),
      (game) async {
        await settle(game);
        game.economy.earnClick();
        await play(game, 31);
        expect(client.reports, hasLength(1));
        final report = client.reports.single;
        expect(report.runId, 'run-1');
        expect(report.snapshot.seq, 1);
        expect(report.snapshot.totalEarned, game.economy.totalEarned);
        expect(game.runSeq, 1);
        expect(game.persistence.load().runSeq, 1);

        game.router.pushNamed('pause');
        await settle(game);
        await play(game, 31);
        expect(client.reports, hasLength(1));
      },
    );

    testWithGame<FifflarUffeGame>(
      'a lost response is recovered through the run state',
      () => FifflarUffeGame(highscoreClient: client),
      (game) async {
        await settle(game);
        client
          ..serverSeq = 2
          ..reportError = HighscoreError.badSequence;
        await play(game, 31);
        expect(client.stateRequests, 1);
        expect(game.runSeq, 2);
        await play(game, 31);
        expect(client.reports.single.snapshot.seq, 3);
      },
    );

    testWithGame<FifflarUffeGame>(
      'an implausible report flags the run and hides submission',
      () {
        SharedPreferences.setMockInitialValues({
          'fifflar_uffe.menu_seen': true,
          'fifflar_uffe.save.v1': jsonEncode({
            ...finishedSave(runId: 'run-9'),
            'elapsedDays': Timeline.totalDays - 400,
          }),
        });
        return FifflarUffeGame(highscoreClient: client);
      },
      (game) async {
        await settle(game);
        client.reportError = HighscoreError.implausible;
        await play(game, 31);
        expect(game.runFlagged, isTrue);
        expect(game.persistence.load().runFlagged, isTrue);
        await play(game, 25);
        final page = await reachGameOver(game);
        expect(page.panel.children.whereType<NameInputComponent>(), isEmpty);
      },
    );

    testWithGame<FifflarUffeGame>(
      'the game over screen submits the final state with a name',
      () {
        SharedPreferences.setMockInitialValues({
          'fifflar_uffe.menu_seen': true,
          'fifflar_uffe.save.v1': jsonEncode(finishedSave(runId: 'run-9')),
        });
        return FifflarUffeGame(highscoreClient: client);
      },
      (game) async {
        final page = await reachGameOver(game);
        expect(game.canSubmitHighscore, isTrue);
        expect(
          page.panel.children.whereType<NameInputComponent>(),
          hasLength(1),
        );
        final input = page.panel.children
            .whereType<NameInputComponent>()
            .single;
        input.updateEditingValue(const TextEditingValue(text: '  Uffe  K '));
        pressSubmit(game, page);
        await settle(game);
        expect(client.submissions, hasLength(1));
        final submission = client.submissions.single;
        expect(submission.runId, 'run-9');
        expect(submission.name, 'Uffe K');
        expect(submission.snapshot.seq, 4);
        expect(submission.snapshot.totalEarned, game.economy.totalEarned);
        expect(submission.snapshot.owned, {'hire_cleaner': 1});
        expect(game.highscoreSubmitted, isTrue);
        expect(game.highscoreRank, 1);
        expect(game.highscoreName, 'Uffe K');
        final save = game.persistence.load();
        expect(save.highscoreSubmitted, isTrue);
        expect(save.highscoreRank, 1);
        expect(game.canSubmitHighscore, isFalse);
        expect(page.panel.children.whereType<NameInputComponent>(), isEmpty);
        final toHighscores = page.panel.children.whereType<GameButton>().where(
          (button) => button.label(game.i18n.strings) == 'Till topplistan',
        );
        expect(toHighscores, hasLength(1));
        toHighscores.single.onPressed!();
        await settle(game);
        expect(game.router.currentRoute, game.router.routes['highscore']);
        game.router.pop();
        await settle(game);

        game.restartRun();
        await settle(game);
        expect(game.highscoreSubmitted, isFalse);
        expect(game.highscoreRank, isNull);
        expect(game.runId, 'run-1');
        expect(client.runCounter, 1);
      },
    );

    testWithGame<FifflarUffeGame>(
      'a score below the submitted best only offers the highscore list',
      () {
        SharedPreferences.setMockInitialValues({
          'fifflar_uffe.menu_seen': true,
          'fifflar_uffe.save.v1': jsonEncode(finishedSave(runId: 'run-9')),
        });
        client.leaderboard = const Leaderboard(
          top: [HighscoreEntry(rank: 1, name: 'Uffe', score: 1000, isMe: true)],
          me: HighscoreEntry(rank: 1, name: 'Uffe', score: 1000, isMe: true),
        );
        return FifflarUffeGame(highscoreClient: client);
      },
      (game) async {
        final page = await reachGameOver(game);
        expect(game.beatsSubmittedBest, isFalse);
        expect(game.canSubmitHighscore, isFalse);
        expect(page.panel.children.whereType<NameInputComponent>(), isEmpty);
        expect(page.panel.children.whereType<SendButton>(), isEmpty);
        final toHighscores = page.panel.children.whereType<GameButton>().where(
          (button) => button.label(game.i18n.strings) == 'Till topplistan',
        );
        expect(toHighscores, hasLength(1));
      },
    );

    testWithGame<FifflarUffeGame>(
      'invalid names are rejected before anything is sent',
      () {
        SharedPreferences.setMockInitialValues({
          'fifflar_uffe.menu_seen': true,
          'fifflar_uffe.save.v1': jsonEncode(finishedSave(runId: 'run-9')),
        });
        return FifflarUffeGame(highscoreClient: client);
      },
      (game) async {
        final page = await reachGameOver(game);
        final input = page.panel.children
            .whereType<NameInputComponent>()
            .single;
        input.updateEditingValue(const TextEditingValue(text: '<script>'));
        pressSubmit(game, page);
        await settle(game);
        expect(client.submissions, isEmpty);
        expect(game.highscoreSubmitted, isFalse);
        input.updateEditingValue(
          const TextEditingValue(text: 'ElvaTeckenLångt'),
        );
        expect(input.text, 'ElvaTecken');
      },
    );

    testWithGame<FifflarUffeGame>(
      'a rejected submission keeps the run unsubmitted',
      () {
        SharedPreferences.setMockInitialValues({
          'fifflar_uffe.menu_seen': true,
          'fifflar_uffe.save.v1': jsonEncode(finishedSave(runId: 'run-9')),
        });
        return FifflarUffeGame(highscoreClient: client);
      },
      (game) async {
        await reachGameOver(game);
        client.submitError = HighscoreError.tooEarly;
        await expectLater(
          game.submitHighscore('Uffe'),
          throwsA(isA<HighscoreException>()),
        );
        expect(game.highscoreSubmitted, isFalse);
        expect(game.canSubmitHighscore, isTrue);
      },
    );

    testWithGame<FifflarUffeGame>(
      'breaking capitalism is reported once with the final state',
      () {
        SharedPreferences.setMockInitialValues({
          'fifflar_uffe.menu_seen': true,
          'fifflar_uffe.save.v1': jsonEncode({
            'balance': 0.0,
            'totalEarned': 0.0,
            'elapsedDays': 0.0,
            'owned': <String, int>{},
            'runId': 'run-9',
            'runSeq': 0,
          }),
        });
        return FifflarUffeGame(highscoreClient: client);
      },
      (game) async {
        await settle(game);
        game.economy.baseClickValue = 1e15;
        game.economy.earnClick();
        await settle(game);
        expect(
          game.router.currentRoute,
          game.router.routes['brokenCapitalism'],
        );
        expect(client.brokenReports, hasLength(1));
        expect(client.brokenReports.single.snapshot.balance, 1e15);
        expect(game.capitalismReported, isTrue);
        expect(game.persistence.load().capitalismReported, isTrue);
        game.economy.earnClick();
        await settle(game);
        expect(client.brokenReports, hasLength(1));
      },
    );
  });

  group('offline mode', () {
    testWithGame<FifflarUffeGame>(
      'an unreachable backend hides everything',
      () => FifflarUffeGame(
        highscoreClient: FakeHighscoreClient()..online = false,
      ),
      (game) async {
        await settle(game);
        expect(game.highscore.available.value, isFalse);
        expect(game.runId, isNull);
        game.router.pushNamed('mainMenu');
        await settle(game);
        expect(menuButtons(game), hasLength(3));
      },
    );

    testWithGame<FifflarUffeGame>(
      'a rate limited player plays offline',
      () => FifflarUffeGame(
        highscoreClient: FakeHighscoreClient()..rateLimited = true,
      ),
      (game) async {
        await settle(game);
        expect(game.runId, isNull);
        expect(game.highscore.available.value, isFalse);
        game.router.pushNamed('mainMenu');
        await settle(game);
        expect(menuButtons(game), hasLength(3));
      },
    );

    testWithGame<FifflarUffeGame>(
      'the submit section is hidden at game over when offline',
      () {
        SharedPreferences.setMockInitialValues({
          'fifflar_uffe.menu_seen': true,
          'fifflar_uffe.save.v1': jsonEncode(finishedSave(runId: 'run-9')),
        });
        return FifflarUffeGame(
          highscoreClient: FakeHighscoreClient()..online = false,
        );
      },
      (game) async {
        final page = await reachGameOver(game);
        expect(game.canSubmitHighscore, isFalse);
        expect(page.panel.children.whereType<NameInputComponent>(), isEmpty);
      },
    );
  });

  test('names are cleaned and validated like the server does', () {
    expect(GameOverPage.cleanName('  Uffe   K  '), 'Uffe K');
    expect(GameOverPage.isValidName('Uffe K'), isTrue);
    expect(GameOverPage.isValidName('Åsa-Britt!'), isTrue);
    expect(GameOverPage.isValidName(''), isFalse);
    expect(GameOverPage.isValidName('<script>'), isFalse);
    expect(GameOverPage.isValidName('ElvaTecken!'), isFalse);
  });
}
