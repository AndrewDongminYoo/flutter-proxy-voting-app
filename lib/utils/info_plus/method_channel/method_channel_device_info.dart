// 🎯 Dart imports:
import 'dart:async';
// 🐦 Flutter imports:
import 'package:flutter/services.dart';
// 📦 Package imports:
import 'package:meta/meta.dart';
// 🌎 Project imports:
import '../device_info_plus/device_info_interface.dart';

class MethodChannelDeviceInfo extends DeviceInfoPlatform {
  @visibleForTesting
  MethodChannel channel = const MethodChannel('bside.native.dev/info');

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
