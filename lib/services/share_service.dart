import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:fifflar_uffe/services/share_card.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService._();

  static const String _fileName = 'fifflar-uffe.png';
  static const String _siteUrl = 'https://fifflar-uffe.se';

  static Future<void> shareResult(FifflarUffeGame game) async {
    final strings = game.i18n.strings;
    final card = ShareCard(
      background: game.images.fromCache(AssetPaths.background),
      head: game.images.fromCache(AssetPaths.uffeHead),
      strings: strings,
      totalEarned: game.economy.totalEarned,
    );
    final bytes = await card.toPng();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'image/png', name: _fileName)],
        fileNameOverrides: const [_fileName],
        subject: strings.shareHeadline,
        text: '${strings.shareHeadline} ${strings.shareTagline} $_siteUrl',
      ),
    );
  }
}
