import 'dart:ui';

import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/model/skill_catalog.dart';
import 'package:fifflar_uffe/routes/skill_tree_route.dart';
import 'package:fifflar_uffe/services/i18n.dart';
import 'package:fifflar_uffe/ui/button_spinner.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/language_flag_button.dart';
import 'package:fifflar_uffe/ui/localized_text_component.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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
    'a hovered button is tinted lighter and restored on exit',
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
      final skin = button.defaultSkin! as SpriteComponent;
      expect(skin.paint.colorFilter, isNull);
      button.onHoverEnter();
      game.update(0);
      await game.ready();
      expect(skin.children.whereType<ColorEffect>(), hasLength(1));
      game.update(0.5);
      expect(skin.paint.colorFilter, isNotNull);
      expect(
        skin.paint.colorFilter,
        ColorFilter.mode(
          const Color(0xFFFFFFFF).withValues(alpha: 0.25),
          BlendMode.srcATop,
        ),
      );
      button.onHoverExit();
      game.update(0);
      await game.ready();
      game.update(0.5);
      expect(
        skin.paint.colorFilter,
        ColorFilter.mode(
          const Color(0xFFFFFFFF).withValues(alpha: 0),
          BlendMode.srcATop,
        ),
      );
    },
  );

  testWithGame<FifflarUffeGame>(
    'plain tappable controls are tinted on hover too',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      final flag = LanguageFlagButton(language: AppLanguage.en);
      game.add(flag);
      game.update(0);
      await game.ready();
      flag.onHoverEnter();
      game.update(0);
      await game.ready();
      final tinted = flag.descendants().where(
        (component) => component.children.whereType<ColorEffect>().isNotEmpty,
      );
      expect(tinted, hasLength(2));
      game.update(0.5);
      for (final sprite in flag.children.whereType<SpriteComponent>()) {
        expect(sprite.paint.colorFilter, isNotNull);
      }
    },
  );

  testWithGame<FifflarUffeGame>(
    'hovering a skill node leaves its texts untouched',
    FifflarUffeGame.new,
    (game) async {
      game.update(0);
      await game.ready();
      final node = SkillNodeComponent(skill: skillCatalog.first);
      game.add(node);
      game.update(0);
      await game.ready();
      node.onHoverEnter();
      game.update(0);
      await game.ready();
      for (final text in node.descendants().whereType<TextComponent>()) {
        expect(text.children.whereType<ColorEffect>(), isEmpty);
      }
      final tintedSprites = node
          .descendants()
          .whereType<SpriteComponent>()
          .where(
            (sprite) => sprite.children.whereType<ColorEffect>().isNotEmpty,
          );
      expect(tintedSprites, isNotEmpty);
    },
  );
}
