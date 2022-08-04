// 🐦 Flutter imports:
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package_info_data.dart';
import 'package_info_interface.dart';

class MethodChannelPackageInfo extends PackageInfoPlatform {
  static const MethodChannel _channel = MethodChannel('bside.native.dev/info');
  @override
  Future<PackageInfoData> getAll() async {
    final map =
        await _channel.invokeMapMethod<String, dynamic>('getPackageInfo');
    return PackageInfoData(
      appName: map!['appName'] ?? '',
      packageName: map['packageName'] ?? '',
      version: map['version'] ?? '',
      buildNumber: map['buildNumber'] ?? '',
      buildSignature: map['buildSignature'] ?? '',
    );
  }
}
