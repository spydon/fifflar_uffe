import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';

class IncomeComponent extends Component with HasGameReference<FifflarUffeGame> {
  @override
  void update(double dt) {
    game.economy.tick(dt);
  }
}
