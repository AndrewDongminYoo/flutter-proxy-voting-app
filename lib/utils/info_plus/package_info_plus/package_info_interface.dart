// 🌎 Project imports:
import '../plugin_platform_interface.dart';
import 'package_info_data.dart';
import 'method_channel_package_info.dart';

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
