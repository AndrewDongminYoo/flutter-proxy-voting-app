import 'package:flutter/services.dart';

class Battery {
  static const platform = MethodChannel('samples.flutter.dev/battery');
  static void getBattery() async {
    String battery = 'empty';
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      battery = 'Battery Level at $result %.';
    } on Exception catch (e, s) {
      battery = 'error $e, stack $s';
    } finally {
      // ignore: avoid_print
      print(battery);
    }
  }
}
