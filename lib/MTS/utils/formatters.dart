import 'package:intl/intl.dart';

DateFormat _formatter = DateFormat('yyyyMMdd');

hypen(String num) {
  try {
    return '${num.substring(0, 3)}-${num.substring(3, 7)}-${num.substring(7)}';
  } catch (e) {
    return num;
  }
}

String dayOf(String day) {
  DateFormat formattor = DateFormat('yyyy-MM-dd');
  DateTime date = DateTime.parse(day);
  return formattor.format(date);
}

String today() {
  DateTime dateTime = DateTime.now();
  return _formatter.format(dateTime);
}

String sixAgo(String dDay) {
  final now = DateTime.tryParse(dDay) ?? DateTime.now();
  Duration duration = const Duration(days: 180); // 6개월
  DateTime monthAgo = now.subtract(duration);
  return _formatter.format(monthAgo);
}

dynamic comma(dynamic value) {
  if (value == null) return '0';
  if (value is String) {
    if (value.isEmpty) return '0';
    try {
      double num = double.parse(value.trim());
      NumberFormat comma = NumberFormat.decimalPattern();
      return comma.format(num);
    } on FormatException {
      return value.trim();
    }
  }
}
