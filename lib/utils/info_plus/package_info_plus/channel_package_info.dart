// 🌎 Project imports:
import '../../channel.dart';
import 'package_info_data.dart';
import 'package_info_interface.dart';

class MethodChannelPackageInfo extends PackageInfoPlatform {
  @override
  Future<PackageInfoData> getAll() async {
    final map =
        await channel.invokeMapMethod<String, dynamic>('getPackageInfo');
    return PackageInfoData(
      appName: map!['appName'] ?? '',
      packageName: map['packageName'] ?? '',
      version: map['version'] ?? '',
      buildNumber: map['buildNumber'] ?? '',
      buildSignature: map['buildSignature'] ?? '',
    );
  }
}
