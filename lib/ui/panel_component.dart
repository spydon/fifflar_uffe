import 'package:fifflar_uffe/game/assets.dart';
import 'package:fifflar_uffe/game/fifflar_uffe_game.dart';
import 'package:flame/components.dart';

class PanelComponent extends NineTileBoxComponent
    with HasGameReference<FifflarUffeGame> {
  PanelComponent({super.size, super.position, super.anchor, super.priority});

  @override
  Future<void> onLoad() async {
    nineTileBox = NineTileBox.withGrid(
      Sprite(game.images.fromCache(AssetPaths.panelFrame)),
      leftWidth: 60,
      rightWidth: 60,
      topHeight: 60,
      bottomHeight: 70,
    );
  }
}
