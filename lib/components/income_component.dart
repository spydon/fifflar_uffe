import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';

class IncomeComponent extends TimerComponent
    with HasGameReference<FifflarUffeGame> {
  IncomeComponent() : super(period: 1, repeat: true);

  @override
  void onTick() {
    game.economy.tick(1);
  }
}
