import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class SoundService {
  SoundService({SoLoud? soloud, Random? random})
    : _soloud = soloud ?? SoLoud.instance,
      _random = random ?? Random();

  static const List<String> coinPaths = [
    'assets/sounds/coin_1.mp3',
    'assets/sounds/coin_2.mp3',
    'assets/sounds/coin_3.mp3',
  ];
  static const double _coinVolume = 0.8;

  final SoLoud _soloud;
  final Random _random;
  final List<AudioSource> _coins = [];
  bool _ready = false;

  bool get isReady => _ready;

  Future<void> init() async {
    try {
      if (!_soloud.isInitialized) {
        await _soloud.init();
      }
      for (final path in coinPaths) {
        _coins.add(await _soloud.loadAsset(path));
      }
      _ready = true;
    } on Exception catch (error) {
      debugPrint('Sound disabled: $error');
    }
  }

  void playCoin() {
    if (!_ready || _coins.isEmpty) {
      return;
    }
    final source = _coins[_random.nextInt(_coins.length)];
    _soloud.play(source, volume: _coinVolume);
  }

  void dispose() {
    if (_ready) {
      _soloud.deinit();
      _ready = false;
    }
  }
}
