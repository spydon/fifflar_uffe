import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const GameWidget.managed(gameFactory: FifflarUffeGame.new));
}
