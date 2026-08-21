import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/ui/button_spinner.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/lightened_sprite_component.dart';
import 'package:fifflar_uffe/ui/localized_text_component.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'fifflar_uffe.menu_seen': true});
  });

  testWithGame<FifflarUffeGame>(
    'a busy button shows a spinner instead of its label and ignores taps',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      var presses = 0;
      final button = GameButton(
        label: (strings) => strings.share,
        size: Vector2(280, 92),
        onPressed: () => presses++,
      );
      game.add(button);
      game.update(0);
      await game.ready();
      expect(button.descendants().whereType<ButtonSpinner>(), isEmpty);
      expect(
        button.descendants().whereType<LocalizedTextComponent>(),
        hasLength(1),
      );

      button.isBusy = true;
      game.update(0);
      await game.ready();
      expect(button.isDisabled, isTrue);
      expect(button.descendants().whereType<ButtonSpinner>(), hasLength(1));
      expect(button.descendants().whereType<LocalizedTextComponent>(), isEmpty);
      button.onTapDown(createTapDownEvents(game: game));
      expect(presses, 0);

      button.isBusy = false;
      game.update(0);
      await game.ready();
      expect(button.isDisabled, isFalse);
      expect(button.descendants().whereType<ButtonSpinner>(), isEmpty);
      expect(
        button.descendants().whereType<LocalizedTextComponent>(),
        hasLength(1),
      );
      button.onTapDown(createTapDownEvents(game: game));
      expect(presses, 1);
    },
  );

  testWithGame<FifflarUffeGame>(
    'a hovered button shows a lightened skin',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      final button = GameButton(
        label: (strings) => strings.share,
        onPressed: () {},
      );
      game.add(button);
      game.update(0);
      await game.ready();
      final hover = button.skinsMap[ButtonState.hover];
      expect(hover, isA<LightenedSpriteComponent>());
      expect(hover!.parent, isNull);
      // ignore: invalid_use_of_protected_member
      button.setState(ButtonState.hover);
      game.update(0);
      await game.ready();
      // ignore: invalid_use_of_protected_member
      expect(hover.parent, button.skinContainer);
      // ignore: invalid_use_of_protected_member
      button.setState(ButtonState.up);
      game.update(0);
      await game.ready();
      expect(hover.parent, isNull);
    },
  );
}
