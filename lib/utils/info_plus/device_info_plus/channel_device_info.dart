// 🎯 Dart imports:
import 'dart:async' show Future;

// 🌎 Project imports:
import '../../global_channel.dart';
import 'device_info_interface.dart';
import 'model/model.dart';

class MethodChannelDeviceInfo extends DeviceInfoPlatform {
  @override
  Future<AndroidDeviceInfo> androidInfo() async {
    return AndroidDeviceInfo.fromMap(
      (await channel.invokeMethod('getDeviceInfo')) as Map<String, dynamic>,
    );
  }

  @override
  Future<IosDeviceInfo> iosInfo() async {
    return IosDeviceInfo.fromMap(
      (await channel.invokeMethod('getDeviceInfo')) as Map<String, dynamic>,
    );
  }
}
