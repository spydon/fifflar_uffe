import 'dart:async';
import 'dart:math';

import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/timeline.dart';
import 'package:fifflar_uffe/routes/share_preview_route.dart';
import 'package:fifflar_uffe/services/highscore_client.dart';
import 'package:fifflar_uffe/services/share_service.dart';
import 'package:fifflar_uffe/services/strings.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/localized_link_component.dart';
import 'package:fifflar_uffe/ui/localized_text_box_component.dart';
import 'package:fifflar_uffe/ui/localized_text_component.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/name_input_component.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:fifflar_uffe/ui/send_button.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:fifflar_uffe/util/sek_format.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class GameOverRoute extends Route with HasGameRef<FifflarUffeGame> {
  GameOverRoute()
    : super(GameOverPage.new, transparent: true, maintainState: false);

  @override
  void onPush(Route? previousRoute) {
    gameRef.world.updatePaused = true;
    unawaited(gameRef.highscore.probe());
  }

  @override
  void onPop(Route nextRoute) {
    gameRef.world.updatePaused = false;
  }
}

class GameOverPage extends ModalPage {
  GameOverPage()
    : super(designSize: Vector2(700, 480), dismissOnScrimTap: false);

  static const int maxNameLength = 10;
  static const double firstRetryDelay = 2;
  static const double maxRetryDelay = 30;
  static const double _sendGap = 12;
  static final RegExp _allowedName = RegExp(
    r"^[\p{L}\p{N} .,_!?'-]+$",
    unicode: true,
  );

  late final PanelComponent _background;
  late final LocalizedTextBoxComponent _appeal;
  late final LocalizedTextComponent _finalScore;
  late final LocalizedTextBoxComponent _submitHint;
  late final NameInputComponent _nameInput;
  late final SendButton _send;
  late final GameButton _toHighscores;
  late final LocalizedTextBoxComponent _status;
  late final LocalizedTextBoxComponent _satire;
  late final LocalizedLinkComponent _referencesLink;
  late final GameButton _playAgain;
  late final GameButton _continue;
  late final GameButton _share;

  bool _built = false;
  bool _submitting = false;
  bool _seenAvailable = false;
  bool _probing = false;
  Timer? _retry;
  double _retryDelay = firstRetryDelay;
  HighscoreError? _error;
  bool _invalidName = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final narrow = isNarrowScreen;
    resizePanel(narrow ? Vector2(460, 640) : Vector2(700, 480));
    final center = designSize.x / 2;
    final textWidth = narrow ? 396.0 : 580.0;
    final bodyStyle = narrow
        ? TextStyles.enlarged(TextStyles.paragraph, 1.3)
        : TextStyles.paragraph;
    final infoStyle = narrow
        ? TextStyles.enlarged(TextStyles.info, 1.25)
        : TextStyles.info;
    final linkStyle = narrow
        ? TextStyles.enlarged(TextStyles.eventLink, 1.3)
        : TextStyles.eventLink;
    panel.addAll([
      _background = PanelComponent(size: designSize.clone()),
      PanelHeader(
        title: (strings) => strings.gameOverTitle,
        size: Vector2(narrow ? 400 : 560, 68),
        position: Vector2(center, 0),
        anchor: Anchor.center,
      ),
      _appeal = LocalizedTextBoxComponent(
        selector: (strings) => strings.voteAppeal(
          strings.formatDayMonth(Timeline.electionDate),
        ),
        textRenderer: bodyStyle,
        boxConfig: TextBoxConfig(maxWidth: textWidth),
        align: Anchor.topCenter,
        anchor: Anchor.topCenter,
        position: Vector2(center, 62),
      ),
      _finalScore = LocalizedTextComponent(
        selector: (strings) =>
            '${strings.finalScore}: ${formatSek(gameRef.economy.totalEarned)}',
        textRenderer: narrow
            ? TextStyles.enlarged(TextStyles.body, 1.15)
            : TextStyles.body,
        anchor: Anchor.center,
      ),
      _status = LocalizedTextBoxComponent(
        selector: _statusText,
        textRenderer: infoStyle,
        boxConfig: TextBoxConfig(maxWidth: textWidth),
        align: Anchor.topCenter,
        anchor: Anchor.topCenter,
      ),
      _satire = LocalizedTextBoxComponent(
        selector: (strings) => strings.aboutSatire,
        textRenderer: infoStyle,
        boxConfig: TextBoxConfig(maxWidth: textWidth),
        align: Anchor.topCenter,
        anchor: Anchor.topCenter,
      ),
      _referencesLink = LocalizedLinkComponent(
        selector: (strings) => strings.references,
        url: 'references.html',
        textRenderer: linkStyle,
        anchor: Anchor.center,
      ),
      _playAgain = GameButton(
        label: (strings) => strings.playAgain,
        anchor: Anchor.center,
        onPressed: () {
          gameRef.restartRun();
          close();
        },
      ),
      _continue = GameButton(
        label: (strings) => strings.continuePlaying,
        color: GameButtonColor.blue,
        anchor: Anchor.center,
        onPressed: () {
          gameRef.continueRun();
          close();
        },
      ),
      _share = GameButton(
        label: (strings) => strings.share,
        color: GameButtonColor.blue,
        anchor: Anchor.center,
        onPressed: _shareResult,
      ),
    ]);
    _nameInput = NameInputComponent(
      maxLength: maxNameLength,
      initialText: gameRef.highscoreName ?? '',
      anchor: Anchor.center,
      onSubmitted: () => unawaited(_submitScore()),
    );
    _send = SendButton(
      anchor: Anchor.center,
      onPressed: () => unawaited(_submitScore()),
    );
    _toHighscores = GameButton(
      label: (strings) => strings.openHighscores,
      color: GameButtonColor.yellow,
      anchor: Anchor.center,
      onPressed: () => gameRef.router.pushNamed('highscore'),
    );
    _submitHint = LocalizedTextBoxComponent(
      selector: (strings) => strings.submitExplanation,
      textRenderer: infoStyle,
      boxConfig: TextBoxConfig(maxWidth: textWidth),
      align: Anchor.topCenter,
      anchor: Anchor.topCenter,
    );
    _submitHint.size.addListener(_layoutContent);
    add(_FocusCatcher(onTap: _nameInput.unfocus));
    _appeal.size.addListener(_layoutContent);
    _status.size.addListener(_layoutContent);
    _satire.size.addListener(_layoutContent);
    _built = true;
    _refresh();
  }

  @override
  void onMount() {
    super.onMount();
    _seenAvailable = gameRef.highscore.available.value;
    gameRef.highscore.available.addListener(_onAvailabilityChanged);
    unawaited(_probe());
  }

  @override
  void onRemove() {
    gameRef.highscore.available.removeListener(_onAvailabilityChanged);
    _retry = null;
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _retry?.update(dt);
  }

  void _onAvailabilityChanged() {
    if (gameRef.highscore.available.value) {
      _seenAvailable = true;
      _retryDelay = firstRetryDelay;
      _retry = null;
    } else {
      _scheduleRetry();
    }
    _refresh();
  }

  Future<void> _probe() async {
    _retry = null;
    _probing = true;
    try {
      await gameRef.highscore.probe();
    } finally {
      _probing = false;
    }
    if (!isMounted) {
      return;
    }
    if (!gameRef.highscore.available.value) {
      _scheduleRetry();
    }
    _refresh();
  }

  void _scheduleRetry() {
    if (_probing || _retry != null) {
      return;
    }
    _retry = Timer(_retryDelay, onTick: () => unawaited(_probe()));
    _retryDelay = min(_retryDelay * 2, maxRetryDelay);
  }

  bool get _showSubmitSection =>
      gameRef.hasUnsubmittedScore &&
      (gameRef.highscore.available.value || _seenAvailable);

  bool get _showHighscoresButton =>
      gameRef.highscore.available.value && !_showSubmitSection;

  String _statusText(Strings strings) {
    if (gameRef.highscoreSubmitted) {
      return '';
    }
    if (_invalidName) {
      return strings.invalidName;
    }
    return switch (_error) {
      null => '',
      HighscoreError.tooEarly => strings.submitTooEarly,
      HighscoreError.alreadySubmitted => strings.submitAlreadyDone,
      HighscoreError.cooldown => strings.submitCooldown,
      HighscoreError.invalidName => strings.invalidName,
      HighscoreError.flagged ||
      HighscoreError.implausible ||
      HighscoreError.runNotFinished ||
      HighscoreError.invalidState ||
      HighscoreError.invalidScore => strings.submitRejected,
      _ => strings.submitFailed,
    };
  }

  void _refresh() {
    if (!_built) {
      return;
    }
    final show = _showSubmitSection;
    _setVisible(_nameInput, show);
    _setVisible(_submitHint, show);
    _setVisible(_send, show);
    _setVisible(_toHighscores, _showHighscoresButton);
    _send.isDisabled = _submitting;
    _status.text = _statusText(gameRef.i18n.strings);
    _layoutContent();
  }

  void _setVisible(Component component, bool visible) {
    if (visible && component.parent == null) {
      panel.add(component);
    } else if (!visible && component.parent != null) {
      component.removeFromParent();
    }
  }

  void _layoutContent() {
    final narrow = isNarrowScreen;
    final center = designSize.x / 2;
    var y = _appeal.position.y + _appeal.size.y + 24;
    _finalScore.position = Vector2(center, y);
    y += 42;
    if (_showSubmitSection) {
      _submitHint.position = Vector2(center, y);
      y += _submitHint.size.y + 10;
      final rowWidth = _nameInput.size.x + _sendGap + _send.size.x;
      final rowLeft = center - rowWidth / 2;
      final rowMiddle = y + _nameInput.size.y / 2;
      _nameInput.position = Vector2(
        rowLeft + _nameInput.size.x / 2,
        rowMiddle,
      );
      _send.position = Vector2(
        rowLeft + rowWidth - _send.size.x / 2,
        rowMiddle,
      );
      y += _nameInput.size.y + 14;
    }
    if (_showHighscoresButton) {
      _toHighscores.position = Vector2(center, y + 40);
      y += 80 + 14;
    }
    if (_status.text.isNotEmpty) {
      _status.position = Vector2(center, y);
      y += _status.size.y + 14;
    }
    y += 6;
    if (narrow) {
      _playAgain.position = Vector2(center, y + 40);
      _continue.position = Vector2(center, y + 132);
      _share.position = Vector2(center, y + 224);
      y += 224 + 40 + 30;
    } else {
      _playAgain.position = Vector2(center - 120, y + 40);
      _continue.position = Vector2(center + 120, y + 40);
      _share.position = Vector2(center, y + 132);
      y += 132 + 40 + 30;
    }
    _satire.position = Vector2(center, y);
    y += _satire.size.y + 20;
    _referencesLink.position = Vector2(center, y);
    y += 36;
    _background.size = Vector2(designSize.x, y);
    resizePanel(Vector2(designSize.x, y));
  }

  static String cleanName(String raw) =>
      raw.replaceAll(RegExp(r'\s+'), ' ').trim();

  static bool isValidName(String name) =>
      name.isNotEmpty &&
      name.length <= maxNameLength &&
      _allowedName.hasMatch(name);

  Future<void> _submitScore() async {
    if (_submitting || !_showSubmitSection) {
      return;
    }
    final name = cleanName(_nameInput.text);
    _invalidName = !isValidName(name);
    _error = null;
    if (_invalidName) {
      _refresh();
      return;
    }
    _nameInput.unfocus();
    _submitting = true;
    _refresh();
    try {
      await gameRef.submitHighscore(name);
    } on HighscoreException catch (exception) {
      _error = exception.error;
    } on TimeoutException {
      _error = HighscoreError.network;
    } finally {
      _submitting = false;
      if (isMounted) {
        _refresh();
      }
    }
  }

  Future<void> _shareResult() async {
    if (_share.isBusy) {
      return;
    }
    _share.isBusy = true;
    final RenderedCard card;
    try {
      card = await ShareService.renderCard(gameRef);
    } finally {
      if (isMounted) {
        _share.isBusy = false;
      }
    }
    if (!isMounted) {
      card.image.dispose();
      return;
    }
    gameRef.router.pushRoute(
      SharePreviewRoute(png: card.png, image: card.image),
    );
  }
}

class _FocusCatcher extends PositionComponent
    with TapCallbacks, HasGameRef<FifflarUffeGame> {
  _FocusCatcher({required this.onTap}) : super(priority: -1);

  final void Function() onTap;

  @override
  Future<void> onLoad() async {
    size = gameRef.size;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
