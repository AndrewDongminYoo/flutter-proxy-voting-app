// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import 'channel_device_info.dart';
import '../plugin_platform_interface.dart';
import 'model/android_device_info.dart';
import 'model/ios_device_info.dart';

export 'model/android_device_info.dart';
export 'model/base_device_info.dart';
export 'model/ios_device_info.dart';

abstract class DeviceInfoPlatform extends PlatformInterface {
  DeviceInfoPlatform() : super(token: _token);

  static final Object _token = Object();

  static DeviceInfoPlatform _instance = MethodChannelDeviceInfo();

  static DeviceInfoPlatform get instance => _instance;

  static set instance(DeviceInfoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<AndroidDeviceInfo> androidInfo() {
    throw UnimplementedError('androidInfo() has not been implemented.');
  }

  Future<IosDeviceInfo> iosInfo() {
    throw UnimplementedError('iosInfo() has not been implemented.');
  }
}
