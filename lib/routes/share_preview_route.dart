import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fifflar_uffe/services/download_service.dart';
import 'package:fifflar_uffe/services/share_card.dart';
import 'package:fifflar_uffe/services/share_service.dart';
import 'package:fifflar_uffe/ui/game_button.dart';
import 'package:fifflar_uffe/ui/modal_page.dart';
import 'package:fifflar_uffe/ui/panel_close_button.dart';
import 'package:fifflar_uffe/ui/panel_component.dart';
import 'package:fifflar_uffe/ui/panel_header.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class SharePreviewRoute extends Route {
  SharePreviewRoute({required Uint8List png, required ui.Image image})
    : super(
        () => SharePreviewPage(png: png, image: image),
        transparent: true,
      );
}

class SharePreviewPage extends ModalPage {
  SharePreviewPage({required this.png, required this.image})
    : super(designSize: Vector2(700, 480));

  final Uint8List png;
  final ui.Image image;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final narrow = isNarrowScreen;
    final width = narrow ? 460.0 : 700.0;
    final center = width / 2;
    final cardWidth = narrow ? 396.0 : 600.0;
    final cardHeight = cardWidth * ShareCard.height / ShareCard.width;
    const cardTop = 64.0;
    final buttonsTop = cardTop + cardHeight + 28;
    final height = buttonsTop + (narrow ? 172 : 80) + 30;
    resizePanel(Vector2(width, height));
    panel.addAll([
      PanelComponent(size: designSize.clone()),
      PanelHeader(
        title: (strings) => strings.shareTitle,
        size: Vector2(narrow ? 400 : 560, 68),
        position: Vector2(center, 0),
        anchor: Anchor.center,
      ),
      PanelCloseButton(
        position: Vector2(width - 20, 20),
        anchor: Anchor.center,
        onPressed: close,
      ),
      SpriteComponent(
        sprite: Sprite(image),
        size: Vector2(cardWidth, cardHeight),
        anchor: Anchor.topCenter,
        position: Vector2(center, cardTop),
      ),
      GameButton(
        label: (strings) => strings.share,
        color: GameButtonColor.yellow,
        anchor: Anchor.center,
        position: Vector2(narrow ? center : center - 120, buttonsTop + 40),
        onPressed: () => ShareService.shareCard(game, png),
      ),
      GameButton(
        label: (strings) => strings.download,
        color: GameButtonColor.blue,
        anchor: Anchor.center,
        position: Vector2(
          narrow ? center : center + 120,
          buttonsTop + (narrow ? 132 : 40),
        ),
        onPressed: () =>
            DownloadService.downloadPng(png, ShareService.fileName),
      ),
    ]);
  }

  @override
  void onRemove() {
    image.dispose();
    super.onRemove();
  }
}
