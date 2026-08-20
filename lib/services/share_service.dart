import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/share_card.dart';
import 'package:share_plus/share_plus.dart';

typedef RenderedCard = ({ui.Image image, Uint8List png});

class ShareService {
  ShareService._();

  static const String fileName = 'fifflar-uffe';
  static const String _siteUrl = 'https://fifflar-uffe.se';

  static Future<RenderedCard> renderCard(FifflarUffeGame game) async {
    final card = ShareCard(
      background: game.images.fromCache(AssetPaths.background),
      head: game.images.fromCache(AssetPaths.uffeHead),
      strings: game.i18n.strings,
      totalEarned: game.economy.totalEarned,
    );
    final image = await card.toImage();
    final png = await ShareCard.encodePng(image);
    return (image: image, png: png);
  }

  static Future<void> shareCard(FifflarUffeGame game, Uint8List png) {
    final strings = game.i18n.strings;
    return SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(png, mimeType: 'image/png', name: '$fileName.png'),
        ],
        fileNameOverrides: const ['$fileName.png'],
        subject: strings.shareHeadline,
        text: '${strings.shareHeadline} ${strings.shareTagline} $_siteUrl',
      ),
    );
  }
}
