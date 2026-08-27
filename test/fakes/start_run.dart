import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/routes/main_menu_route.dart';
import 'package:fifflar_uffe/ui/game_button.dart';

Future<void> startRun(FifflarUffeGame game) async {
  game.update(0);
  await game.ready();
  game.update(0);
  await game.ready();
  final page = game.router.currentRoute.children
      .whereType<MainMenuPage>()
      .single;
  page.panel.children
      .whereType<GameButton>()
      .firstWhere(
        (button) =>
            button.label(game.i18n.strings) == game.i18n.strings.startPlaying,
      )
      .onPressed!();
  game.update(1);
  await game.ready();
  game.update(0);
  await game.ready();
}
