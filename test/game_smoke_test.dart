import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWithGame<FifflarUffeGame>(
    'game loads with the home route active',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['home']);
      expect(game.world.updatePaused, isFalse);
    },
  );

  testWithGame<FifflarUffeGame>(
    'pause route freezes the world',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      game.router.pushNamed('pause');
      game.update(0);
      await game.ready();
      expect(game.world.updatePaused, isTrue);
      game.router.pop();
      game.update(0);
      await game.ready();
      expect(game.world.updatePaused, isFalse);
    },
  );
}
