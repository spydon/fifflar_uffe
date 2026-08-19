import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const GameWidget.managed(gameFactory: FifflarUffeGame.new));
}
