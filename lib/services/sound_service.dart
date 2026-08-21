import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

enum SoundEffect {
  coin([
    'assets/sounds/coin_1.mp3',
    'assets/sounds/coin_2.mp3',
    'assets/sounds/coin_3.mp3',
  ], volume: 0.8),
  purchase([
    'assets/sounds/door_1.mp3',
    'assets/sounds/door_2.mp3',
    'assets/sounds/door_3.mp3',
  ], volume: 0.7),
  gameOver(['assets/sounds/fanfare.mp3'], volume: 0.9);

  const SoundEffect(this.paths, {required this.volume});

  final List<String> paths;
  final double volume;
}

class SoundService {
  SoundService({SoLoud? soloud, Random? random})
    : _soloud = soloud ?? SoLoud.instance,
      _random = random ?? Random();

  final SoLoud _soloud;
  final Random _random;
  final Map<SoundEffect, List<AudioSource>> _sources = {};
  bool _ready = false;

  bool get isReady => _ready;

  Future<void> init() async {
    try {
      if (!_soloud.isInitialized) {
        await _soloud.init();
      }
      for (final effect in SoundEffect.values) {
        _sources[effect] = [
          for (final path in effect.paths) await _soloud.loadAsset(path),
        ];
      }
      _ready = true;
    } on Exception catch (error) {
      debugPrint('Sound disabled: $error');
    }
  }

  void play(SoundEffect effect) {
    final sources = _sources[effect];
    if (!_ready || sources == null || sources.isEmpty) {
      return;
    }
    final source = sources[_random.nextInt(sources.length)];
    _soloud.play(source, volume: effect.volume);
  }

  void playCoin() => play(SoundEffect.coin);

  void playPurchase() => play(SoundEffect.purchase);

  void playGameOver() => play(SoundEffect.gameOver);

  void dispose() {
    if (_ready) {
      _soloud.deinit();
      _ready = false;
    }
  }
}
