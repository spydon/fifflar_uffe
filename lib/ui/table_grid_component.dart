import 'dart:ui';

import 'package:fifflar_uffe/ui/text_styles.dart';
import 'package:flame/components.dart';

class TableGridComponent extends PositionComponent {
  TableGridComponent({
    required this.columnWidths,
    required this.headerHeight,
    required this.rowHeight,
    required this.rowCount,
    super.position,
    super.priority,
  }) : super(
         size: Vector2(
           columnWidths.fold(0, (sum, width) => sum + width),
           headerHeight + rowHeight * rowCount,
         ),
       );

  static final Paint _linePaint = Paint()
    ..color = TextStyles.lightBrown
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  static final Paint _headerPaint = Paint()..color = const Color(0x338A7156);

  final List<double> columnWidths;
  final double headerHeight;
  final double rowHeight;
  final int rowCount;

  double columnLeft(int column) =>
      columnWidths.take(column).fold(0, (sum, width) => sum + width);

  double rowTop(int row) => headerHeight + rowHeight * row;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, headerHeight), _headerPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _linePaint);
    for (var column = 1; column < columnWidths.length; column++) {
      final x = columnLeft(column);
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _linePaint);
    }
    for (var row = 0; row <= rowCount; row++) {
      final y = rowTop(row);
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _linePaint);
    }
  }
}
