import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../device_info_plus/device_info_interface.dart';

/// An implementation of [DeviceInfoPlatform] that uses method channels.
class MethodChannelDeviceInfo extends DeviceInfoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel channel = const MethodChannel('bside.native.dev/info');

  // Method channel for Android devices
  @override
  Future<AndroidDeviceInfo> androidInfo() async {
    return AndroidDeviceInfo.fromMap(
      (await channel.invokeMethod('getDeviceInfo')).cast<String, dynamic>(),
    );
  }

  // Method channel for iOS devices
  @override
  Future<IosDeviceInfo> iosInfo() async {
    return IosDeviceInfo.fromMap(
      (await channel.invokeMethod('getDeviceInfo')).cast<String, dynamic>(),
    );
  }
}
