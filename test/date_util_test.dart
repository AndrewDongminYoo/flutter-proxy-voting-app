// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:timeago/timeago.dart' as timeago;

// 🌎 Project imports:
import 'package:bside/utils/date_util.dart';

final now = DateTime.now();

void main() {
  group('Counter', () {
    timeago.setLocaleMessages('ko', KoMessages());
    test('a moment ago', () {
      final clock = now.add(const Duration(seconds: 1));
      var result = timeago.format(now, clock: clock, locale: 'ko');
      expect(result, equals('방금 전'));
    });

    test('2 minutes ago', () {
      final clock = now.add(const Duration(minutes: 2));
      var result = timeago.format(now, clock: clock, locale: 'ko');
      expect(result, equals('2분 전'));
    });

    test('1 hour ago', () {
      final clock = now.add(const Duration(minutes: 70));
      var result = timeago.format(now, clock: clock, locale: 'ko');
      expect(result, equals('1시간 전'));
    });

    test('2 days ago', () {
      final clock = now.add(const Duration(days: 2, minutes: 2));
      var result = timeago.format(now, clock: clock, locale: 'ko');
      expect(result, equals('2일 전'));
    });
  });
}
