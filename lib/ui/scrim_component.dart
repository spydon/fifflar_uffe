import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

class ScrimComponent extends RectangleComponent
    with TapCallbacks, HasGameReference<FifflarUffeGame> {
  ScrimComponent({this.onTap})
    : super(paint: Paint()..color = const Color(0x99000000), priority: -1);

  final void Function()? onTap;

  @override
  Future<void> onLoad() async {
    size = game.size;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void onTapUp(TapUpEvent event) {
    onTap?.call();
  }
}
