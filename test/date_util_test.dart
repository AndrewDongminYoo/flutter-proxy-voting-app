// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:timeago/timeago.dart' as timeago;

// 🌎 Project imports:
import 'package:sample/utils/date_util.dart';

final DateTime now = DateTime.now();

void main() {
  group('Counter', () {
    timeago.setLocaleMessages('ko', KoMessages());
    test('a moment ago', () {
      final DateTime clock = now.add(const Duration(seconds: 1));
      String result = timeago.format(now, clock: clock, locale: 'ko');
      expect(result, equals('방금 전'));
    });

    test('2 minutes ago', () {
      final DateTime clock = now.add(const Duration(minutes: 2));
      String result = timeago.format(now, clock: clock, locale: 'ko');
      expect(result, equals('2분 전'));
    });

    test('1 hour ago', () {
      final DateTime clock = now.add(const Duration(minutes: 70));
      String result = timeago.format(now, clock: clock, locale: 'ko');
      expect(result, equals('1시간 전'));
    });

    test('2 days ago', () {
      final DateTime clock = now.add(const Duration(days: 2, minutes: 2));
      String result = timeago.format(now, clock: clock, locale: 'ko');
      expect(result, equals('2일 전'));
    });
  });
}
