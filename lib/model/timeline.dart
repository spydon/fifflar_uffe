import 'package:flutter/foundation.dart';

class Timeline extends ChangeNotifier {
  Timeline({double elapsedDays = 0})
    : _elapsedDays = elapsedDays.clamp(0, totalDays).toDouble();

  static final DateTime startDate = DateTime.utc(2000);
  static final DateTime electionDate = DateTime.utc(2002, 9, 15);
  static const double daysPerSecond = 1;
  static final int totalDays = electionDate.difference(startDate).inDays;

  double _elapsedDays;

  double get elapsedDays => _elapsedDays;

  bool get isOver => _elapsedDays >= totalDays;

  DateTime get currentDate =>
      startDate.add(Duration(days: _elapsedDays.floor()));

  void advance(double seconds) {
    if (isOver) {
      return;
    }
    final previousDay = _elapsedDays.floor();
    _elapsedDays = (_elapsedDays + seconds * daysPerSecond)
        .clamp(0, totalDays)
        .toDouble();
    if (_elapsedDays.floor() != previousDay || isOver) {
      notifyListeners();
    }
  }

  void reset() {
    _elapsedDays = 0;
    notifyListeners();
  }
}
