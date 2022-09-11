// 🎯 Dart imports:
import 'dart:async' show Future;

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 🌎 Project imports:
import '../info_plus.dart';

class PackageInfo {
  PackageInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    this.buildSignature = '',
  });

  static PackageInfo? _fromPlatform;

  static Future<PackageInfo> fromPlatform() async {
    if (_fromPlatform != null) {
      return _fromPlatform!;
    }

    final PackageInfoData platformData =
        await PackageInfoPlatform.instance.getAll();
    _fromPlatform = PackageInfo(
      appName: platformData.appName,
      packageName: platformData.packageName,
      version: platformData.version,
      buildNumber: platformData.buildNumber,
      buildSignature: platformData.buildSignature,
    );
    return _fromPlatform!;
  }

  final String appName;

  final String packageName;

  final String version;

  final String buildNumber;

  final String buildSignature;

  @visibleForTesting
  static void setMockInitialValues({
    required String appName,
    required String packageName,
    required String version,
    required String buildNumber,
    required String buildSignature,
  }) {
    _fromPlatform = PackageInfo(
      appName: appName,
      packageName: packageName,
      version: version,
      buildNumber: buildNumber,
      buildSignature: buildSignature,
    );
  }
}
