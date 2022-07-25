// ignore_for_file: avoid_print
import 'package:flutter/services.dart';

class Battery {
  static const platform = MethodChannel('samples.flutter.dev/battery');
  static void getBattery() async {
    String battery = 'empty';
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      assert(result >= 0 && result <= 100);
      if (result <= 20) {
        print('You need to charge the battery');
      }
      battery = 'Battery Level at $result %.';
    } on Exception catch (e, s) {
      battery = 'error $e, stack $s';
    } finally {
      print(battery);
    }
  }
}
