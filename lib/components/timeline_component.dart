import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';

class TimelineComponent extends Component
    with HasGameReference<FifflarUffeGame> {
  @override
  void update(double dt) {
    game.timeline.advance(dt);
    if (game.timeline.isOver) {
      game.handleGameOver();
    }
  }
}
