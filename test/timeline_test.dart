import 'package:fifflar_uffe/model/timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts on the first of January 2000', () {
    final timeline = Timeline();
    expect(timeline.currentDate, DateTime.utc(2000));
    expect(timeline.isOver, isFalse);
  });

  test('advances eight days per second', () {
    final timeline = Timeline()..advance(1.5);
    expect(timeline.elapsedDays, 12);
    expect(timeline.currentDate, DateTime.utc(2000, 1, 13));
  });

  test('notifies only when the displayed day changes', () {
    final timeline = Timeline();
    var notifications = 0;
    timeline
      ..addListener(() => notifications++)
      ..advance(0.05);
    expect(notifications, 0);
    timeline.advance(0.1);
    expect(notifications, 1);
  });

  test('ends on election day and stops there', () {
    final timeline = Timeline()..advance(Timeline.totalDays + 5);
    expect(timeline.isOver, isTrue);
    expect(timeline.elapsedDays, Timeline.totalDays);
    expect(timeline.currentDate, DateTime.utc(2026, 9, 13));
    timeline.advance(10);
    expect(timeline.elapsedDays, Timeline.totalDays);
  });

  test('continues past election day when unbounded', () {
    final timeline = Timeline()
      ..advance(Timeline.totalDays.toDouble())
      ..continueBeyondEnd()
      ..advance(5);
    expect(timeline.unbounded, isTrue);
    expect(timeline.isOver, isTrue);
    expect(timeline.elapsedDays, Timeline.totalDays + 40);
    expect(timeline.currentDate, DateTime.utc(2026, 10, 23));
  });

  test('loads an unbounded save past election day without clamping', () {
    final timeline = Timeline(
      elapsedDays: Timeline.totalDays + 100,
      unbounded: true,
    );
    expect(timeline.elapsedDays, Timeline.totalDays + 100);
  });

  test('reset returns to the start date and restores the bound', () {
    final timeline = Timeline(elapsedDays: 200, unbounded: true)..reset();
    expect(timeline.elapsedDays, 0);
    expect(timeline.currentDate, DateTime.utc(2000));
    expect(timeline.isOver, isFalse);
    expect(timeline.unbounded, isFalse);
  });
}
