// ignore_for_file: avoid_print

// 🌎 Project imports:
import '../global_channel.dart';

class Battery {
  static Future<String> getBattery() async {
    String battery = 'empty';
    try {
      final int result = await channel.invokeMethod('getBatteryLevel');
      assert(result >= 0 && result <= 100);
      if (result <= 20) {
        print('You need to charge the battery');
      }
      battery = 'Battery Level at $result %.';
    } on Exception catch (e, s) {
      battery = 'error $e, stack $s';
    }
    return battery;
  }
}
