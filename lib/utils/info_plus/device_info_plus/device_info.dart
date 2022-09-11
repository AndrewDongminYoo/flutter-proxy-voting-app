// 🎯 Dart imports:
import 'dart:async' show Future;
import 'dart:io' show Platform;

// 🌎 Project imports:
import 'device_info_interface.dart';
import 'model/model.dart';

class DeviceInfoPlugin {
  DeviceInfoPlugin();

  static DeviceInfoPlatform get _platform => DeviceInfoPlatform.instance;

  AndroidDeviceInfo? _cachedAndroidDeviceInfo;

  Future<AndroidDeviceInfo> get androidInfo async =>
      _cachedAndroidDeviceInfo ??= await _platform.androidInfo();

  IosDeviceInfo? _cachedIosDeviceInfo;

  Future<IosDeviceInfo> get iosInfo async =>
      _cachedIosDeviceInfo ??= await _platform.iosInfo();

  Future<BaseDeviceInfo> get deviceInfo async {
    if (Platform.isAndroid) {
      return androidInfo;
    } else if (Platform.isIOS) {
      return iosInfo;
    }

    throw UnsupportedError('Unsupported platform');
  }
}
