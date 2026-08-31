import 'dart:ui';

import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/localized_text_component.dart';
import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';

class NameInputComponent extends PositionComponent
    with HasGameRef<FifflarUffeGame>, TapCallbacks, TextInputClient {
  NameInputComponent({
    required this.maxLength,
    required this.onSubmitted,
    String initialText = '',
    super.position,
    super.anchor,
    super.priority,
  }) : _value = TextEditingValue(
         text: initialText,
         selection: TextSelection.collapsed(offset: initialText.length),
       ),
       super(size: Vector2(326, 75));

  static const double _textInset = 30;
  static const double _caretPeriod = 1.1;
  static final Paint _caretPaint = Paint()..color = TextStyles.brown;

  final int maxLength;
  final void Function() onSubmitted;

  TextEditingValue _value;
  TextInputConnection? _connection;
  double _caretTime = 0;
  late final TextComponent _text;
  late final LocalizedTextComponent _placeholder;
  late final RectangleComponent _caret;
  bool _built = false;

  String get text => _value.text.trim();

  bool get hasFocus => _connection?.attached ?? false;

  @override
  Future<void> onLoad() async {
    addAll([
      SpriteComponent(
        sprite: Sprite(gameRef.images.fromCache(AssetPaths.labelPill)),
        size: size.clone(),
      ),
      _text = TextComponent(
        text: _value.text,
        textRenderer: TextStyles.body,
        anchor: Anchor.centerLeft,
        position: Vector2(_textInset, size.y / 2 - 3),
      ),
      _placeholder = LocalizedTextComponent(
        selector: (strings) => strings.nameHint,
        textRenderer: TextStyles.placeholder,
        anchor: Anchor.centerLeft,
        position: Vector2(_textInset + 8, size.y / 2 - 3),
      ),
      _caret = RectangleComponent(
        size: Vector2(2, TextStyles.body.getLineMetrics('A').height),
        anchor: Anchor.centerLeft,
        paint: _caretPaint,
      ),
    ]);
    _built = true;
    _refresh();
  }

  @override
  void onRemove() {
    unfocus();
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _caretTime += dt;
    if (_built) {
      _caret.opacity = _caretTime % _caretPeriod <= _caretPeriod / 2 ? 1 : 0;
    }
  }

  void _placeCaret() {
    final offset = _value.selection.isValid
        ? _value.selection.extentOffset.clamp(0, _value.text.length)
        : _value.text.length;
    final prefix = _value.text.substring(0, offset);
    final width = TextStyles.body.getLineMetrics(prefix).width;
    _caret.position = Vector2(_textInset + width + 1, size.y / 2 - 3);
  }

  @override
  void onTapDown(TapDownEvent event) {
    focus();
  }

  void focus() {
    if (hasFocus) {
      return;
    }
    _caretTime = 0;
    _connection =
        TextInput.attach(
            this,
            const TextInputConfiguration(
              inputType: TextInputType.name,
              autocorrect: false,
              enableSuggestions: false,
            ),
          )
          ..setEditingState(_value)
          ..show();
    _refresh();
  }

  void unfocus() {
    _connection?.close();
    _connection = null;
    _refresh();
  }

  @override
  TextEditingValue? get currentTextEditingValue => _value;

  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  void updateEditingValue(TextEditingValue value) {
    var next = value;
    if (next.text.length > maxLength) {
      final truncated = next.text.substring(0, maxLength);
      next = TextEditingValue(
        text: truncated,
        selection: TextSelection.collapsed(offset: truncated.length),
      );
      _connection?.setEditingState(next);
    }
    _value = next;
    _caretTime = 0;
    _refresh();
  }

  @override
  void performAction(TextInputAction action) {
    if (action == TextInputAction.done ||
        action == TextInputAction.go ||
        action == TextInputAction.send) {
      unfocus();
      onSubmitted();
    }
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void connectionClosed() {
    _connection = null;
  }

  void _refresh() {
    if (!_built) {
      return;
    }
    _text.text = _value.text;
    _placeCaret();
    _placeholder.scale = _value.text.isEmpty && !hasFocus
        ? Vector2.all(1)
        : Vector2.zero();
  }
}
