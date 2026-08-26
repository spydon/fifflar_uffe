import 'dart:ui';

import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/strings.dart';
import 'package:fifflar_uffe/ui/localized_text_box_component.dart';
import 'package:flame/components.dart';

class MenuNoteComponent extends PositionComponent
    with HasGameReference<FifflarUffeGame> {
  MenuNoteComponent({
    required this.selector,
    required this.textRenderer,
    required double width,
    super.position,
    super.anchor,
    super.priority,
  }) : super(size: Vector2(width, 0));

  static const double _horizontalPadding = 18;
  static const double _verticalPadding = 14;
  static const double _cornerRadius = 14;
  static const double _tapeWidth = 96;
  static const double _tapeHeight = 22;
  static const double _tapeTilt = -0.05;

  static final Paint _shadowPaint = Paint()
    ..color = const Color(0x33000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  static final Paint _fillPaint = Paint()..color = const Color(0xFFFFF0B3);
  static final Paint _borderPaint = Paint()
    ..color = const Color(0xFFC9A961)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;
  static final Paint _tapePaint = Paint()..color = const Color(0x99D8E6EA);
  static final Paint _tapeEdgePaint = Paint()
    ..color = const Color(0x55FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  final String Function(Strings strings) selector;
  final TextPaint textRenderer;

  late final LocalizedTextBoxComponent _text;

  @override
  Future<void> onLoad() async {
    _text = LocalizedTextBoxComponent(
      selector: selector,
      textRenderer: textRenderer,
      boxConfig: TextBoxConfig(maxWidth: size.x - 2 * _horizontalPadding),
      align: Anchor.topCenter,
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, _verticalPadding),
    );
    add(_text);
    _text.size.addListener(_fit);
    _fit();
  }

  void _fit() {
    size.setValues(size.x, _text.size.y + 2 * _verticalPadding);
  }

  @override
  void render(Canvas canvas) {
    final note = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(_cornerRadius),
    );
    canvas.drawRRect(note.shift(const Offset(0, 4)), _shadowPaint);
    canvas.drawRRect(note, _fillPaint);
    canvas.drawRRect(note, _borderPaint);

    canvas.save();
    canvas.translate(size.x / 2, 0);
    canvas.rotate(_tapeTilt);
    final tape = Rect.fromCenter(
      center: Offset.zero,
      width: _tapeWidth,
      height: _tapeHeight,
    );
    canvas.drawRect(tape, _tapePaint);
    canvas.drawRect(tape, _tapeEdgePaint);
    canvas.restore();
  }
}
