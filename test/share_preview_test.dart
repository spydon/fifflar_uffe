import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/routes/share_preview_route.dart';
import 'package:fifflar_uffe/services/share_card.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/start_run.dart';

ui.Image _fakeCard() {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, ShareCard.width, ShareCard.height),
    ui.Paint()..color = const ui.Color(0xFF123456),
  );
  return recorder.endRecording().toImageSync(
    ShareCard.width.toInt(),
    ShareCard.height.toInt(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWithGame<FifflarUffeGame>(
    'share preview shows the card with share and download buttons',
    FifflarUffeGame.new,
    (game) async {
      await startRun(game);
      final image = _fakeCard();
      game.router.pushRoute(SharePreviewRoute(png: Uint8List(0), image: image));
      game.update(0);
      await game.ready();
      final page = game.router.descendants().whereType<SharePreviewPage>();
      expect(page, hasLength(1));
      final buttons = page.single.descendants().whereType<GameButton>();
      expect(buttons, hasLength(2));
      final preview = page.single.descendants().whereType<SpriteComponent>();
      expect(preview.any((sprite) => sprite.sprite?.image == image), isTrue);

      page.single.close();
      game.update(0.5);
      game.update(0);
      await game.ready();
      expect(game.router.currentRoute, game.router.routes['home']);
    },
  );
}
