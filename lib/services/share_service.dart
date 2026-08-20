import 'dart:typed_data';

import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/share_card.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService._();

  static const String _fileName = 'fifflar-uffe.png';
  static const String _siteUrl = 'https://fifflar-uffe.se';

  static Future<Uint8List> renderCard(FifflarUffeGame game) {
    final card = ShareCard(
      background: game.images.fromCache(AssetPaths.background),
      head: game.images.fromCache(AssetPaths.uffeHead),
      strings: game.i18n.strings,
      totalEarned: game.economy.totalEarned,
    );
    return card.toPng();
  }

  static Future<void> shareCard(FifflarUffeGame game, Uint8List bytes) {
    final strings = game.i18n.strings;
    return SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'image/png', name: _fileName)],
        fileNameOverrides: const [_fileName],
        subject: strings.shareHeadline,
        text: '${strings.shareHeadline} ${strings.shareTagline} $_siteUrl',
      ),
    );
  }
}
