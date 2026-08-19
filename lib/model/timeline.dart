import 'dart:math';

import 'package:flutter/foundation.dart';

class Timeline extends ChangeNotifier {
  Timeline({double elapsedDays = 0, bool unbounded = false})
    : _unbounded = unbounded,
      _elapsedDays = unbounded
          ? max(0, elapsedDays)
          : elapsedDays.clamp(0, totalDays).toDouble();

  static final DateTime startDate = DateTime.utc(2000);
  static final DateTime electionDate = DateTime.utc(2002, 9, 15);
  static final DateTime realElectionDate = DateTime.utc(2026, 9, 13);
  static const double daysPerSecond = 2;
  static final int totalDays = electionDate.difference(startDate).inDays;

  double _elapsedDays;
  bool _unbounded;

  double get elapsedDays => _elapsedDays;

  bool get unbounded => _unbounded;

  bool get isOver => _elapsedDays >= totalDays;

  DateTime get currentDate =>
      startDate.add(Duration(days: _elapsedDays.floor()));

  void continueBeyondEnd() {
    _unbounded = true;
  }

  void advance(double seconds) {
    if (isOver && !_unbounded) {
      return;
    }
    final previousDay = _elapsedDays.floor();
    _elapsedDays += seconds * daysPerSecond;
    if (!_unbounded) {
      _elapsedDays = _elapsedDays.clamp(0, totalDays).toDouble();
    }
    if (_elapsedDays.floor() != previousDay) {
      notifyListeners();
    }
  }

  void reset() {
    _elapsedDays = 0;
    _unbounded = false;
    notifyListeners();
  }
}
