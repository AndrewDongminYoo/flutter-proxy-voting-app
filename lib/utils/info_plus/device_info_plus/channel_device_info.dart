// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import '../../channel.dart';
import 'device_info_interface.dart';

class MethodChannelDeviceInfo extends DeviceInfoPlatform {
  @override
  Future<AndroidDeviceInfo> androidInfo() async {
    return AndroidDeviceInfo.fromMap(
      (await channel.invokeMethod('getDeviceInfo')).cast<String, dynamic>(),
    );
  }

  @override
  Future<IosDeviceInfo> iosInfo() async {
    return IosDeviceInfo.fromMap(
      (await channel.invokeMethod('getDeviceInfo')).cast<String, dynamic>(),
    );
  }
}
