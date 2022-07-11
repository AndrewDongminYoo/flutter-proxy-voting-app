import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show MethodChannel;

abstract class PlatformInterface {
  PlatformInterface({required Object token}) : _instanceToken = token;

  final Object? _instanceToken;

  static void verify(PlatformInterface instance, Object token) {
    _verify(instance, token, preventConstObject: true);
  }

  static void verifyToken(PlatformInterface instance, Object token) {
    _verify(instance, token, preventConstObject: false);
  }

  static void _verify(
    PlatformInterface instance,
    Object token, {
    required bool preventConstObject,
  }) {
    if (instance is MockPlatformInterfaceMixin) {
      bool assertionsEnabled = false;
      assert(() {
        assertionsEnabled = true;
        return true;
      }());
      if (!assertionsEnabled) {
        throw AssertionError(
            '`MockPlatformInterfaceMixin` is not intended for use in release builds.');
      }
      return;
    }
    if (preventConstObject &&
        identical(instance._instanceToken, const Object())) {
      throw AssertionError('`const Object()` cannot be used as the token.');
    }
    if (!identical(token, instance._instanceToken)) {
      throw AssertionError(
          'Platform interfaces must not be implemented with `implements`');
    }
  }
}

@visibleForTesting
abstract class MockPlatformInterfaceMixin implements PlatformInterface {}

class PackageInfoData {
  PackageInfoData({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.buildSignature,
  });

  final String appName;

  final String packageName;

  final String version;

  final String buildNumber;

  final String buildSignature;
}

const MethodChannel _channel =
    MethodChannel('dev.fluttercommunity.plus/package_info');

class MethodChannelPackageInfo extends PackageInfoPlatform {
  @override
  Future<PackageInfoData> getAll() async {
    final map = await _channel.invokeMapMethod<String, dynamic>('getAll');
    return PackageInfoData(
      appName: map!['appName'] ?? '',
      packageName: map['packageName'] ?? '',
      version: map['version'] ?? '',
      buildNumber: map['buildNumber'] ?? '',
      buildSignature: map['buildSignature'] ?? '',
    );
  }
}

abstract class PackageInfoPlatform extends PlatformInterface {
  PackageInfoPlatform() : super(token: _token);

  static final Object _token = Object();

  static PackageInfoPlatform _instance = MethodChannelPackageInfo();

  static PackageInfoPlatform get instance => _instance;

  static set instance(PackageInfoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<PackageInfoData> getAll() {
    throw UnimplementedError('getAll() has not been implemented.');
  }
}

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

    final platformData = await PackageInfoPlatform.instance.getAll();
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
