import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';

class TimelineComponent extends Component with HasGameRef<FifflarUffeGame> {
  @override
  void update(double dt) {
    gameRef.timeline.advance(dt);
    if (gameRef.timeline.isOver) {
      gameRef.handleGameOver();
    }
  }
}
