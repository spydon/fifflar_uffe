import 'package:fifflar_uffe/components/uffe_figure_component.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/speech_bubble_component.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'fifflar_uffe.menu_seen': true});
  });

  Future<UffeFigureComponent> loadFigure(FifflarUffeGame game) async {
    game.update(0);
    await game.ready();
    return game.uffe.descendants().whereType<UffeFigureComponent>().single;
  }

  void poke(FifflarUffeGame game, UffeFigureComponent figure) {
    figure.onTapDown(createTapDownEvents(game: game));
  }

  testWithGame<FifflarUffeGame>(
    'tapping Uffe makes him hop and bob his head before settling down',
    FifflarUffeGame.new,
    (game) async {
      final figure = await loadFigure(game);
      expect(figure.isAirborne, isFalse);
      poke(game, figure);
      game.update(0.05);
      expect(figure.isAirborne, isTrue);
      expect(figure.isLaughing, isTrue);
      for (var i = 0; i < 60; i++) {
        game.update(1 / 30);
      }
      expect(figure.isAirborne, isFalse);
      expect(figure.isLaughing, isFalse);
      expect(figure.position, Vector2.zero());
      expect(figure.head.position, figure.headRestPosition);
    },
  );

  testWithGame<FifflarUffeGame>(
    'spam tapping Uffe never sends him flying off',
    FifflarUffeGame.new,
    (game) async {
      final figure = await loadFigure(game);
      for (var i = 0; i < 200; i++) {
        poke(game, figure);
        game.update(1 / 60);
        expect(figure.position.y, greaterThanOrEqualTo(-30));
        expect(figure.position.y, lessThanOrEqualTo(0));
      }
      for (var i = 0; i < 60; i++) {
        game.update(1 / 30);
      }
      expect(figure.position, Vector2.zero());
    },
  );

  testWithGame<FifflarUffeGame>(
    'Uffe complains after being poked ten times',
    FifflarUffeGame.new,
    (game) async {
      final figure = await loadFigure(game);
      final bubble = game.uffe.children
          .whereType<SpeechBubbleComponent>()
          .single;
      for (var i = 0; i < 9; i++) {
        poke(game, figure);
      }
      expect(bubble.isVisible, isFalse);
      poke(game, figure);
      expect(bubble.isVisible, isTrue);
      final text = bubble.descendants().whereType<TextBoxComponent>().single;
      expect(text.text, game.i18n.strings.pokeWarning);
    },
  );
}
