import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';

class IncomeComponent extends Component with HasGameRef<FifflarUffeGame> {
  @override
  void update(double dt) {
    gameRef.economy.tick(dt);
  }
}
