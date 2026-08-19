import 'package:fifflar_uffe/model/timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts on the first of January 2000', () {
    final timeline = Timeline();
    expect(timeline.currentDate, DateTime.utc(2000));
    expect(timeline.isOver, isFalse);
  });

  test('advances two days per second', () {
    final timeline = Timeline()..advance(1.5);
    expect(timeline.elapsedDays, 3);
    expect(timeline.currentDate, DateTime.utc(2000, 1, 4));
  });

  test('notifies only when the displayed day changes', () {
    final timeline = Timeline();
    var notifications = 0;
    timeline
      ..addListener(() => notifications++)
      ..advance(0.4);
    expect(notifications, 0);
    timeline.advance(0.7);
    expect(notifications, 1);
  });

  test('ends on election day and stops there', () {
    final timeline = Timeline()..advance(Timeline.totalDays + 5);
    expect(timeline.isOver, isTrue);
    expect(timeline.elapsedDays, Timeline.totalDays);
    expect(timeline.currentDate, DateTime.utc(2002, 9, 15));
    timeline.advance(10);
    expect(timeline.elapsedDays, Timeline.totalDays);
  });

  test('reset returns to the start date', () {
    final timeline = Timeline(elapsedDays: 200)..reset();
    expect(timeline.elapsedDays, 0);
    expect(timeline.currentDate, DateTime.utc(2000));
    expect(timeline.isOver, isFalse);
  });
}
