// 🌎 Project imports:
import '../../global_channel.dart';
import 'package_info_data.dart';
import 'package_info_interface.dart';

class MethodChannelPackageInfo extends PackageInfoPlatform {
  @override
  Future<PackageInfoData> getAll() async {
    final Map<String, dynamic>? map =
        await channel.invokeMapMethod<String, dynamic>('getPackageInfo');
    return PackageInfoData(
      appName: (map!['appName'] ?? '') as String,
      packageName: (map['packageName'] ?? '') as String,
      version: (map['version'] ?? '') as String,
      buildNumber: (map['buildNumber'] ?? '') as String,
      buildSignature: (map['buildSignature'] ?? '') as String,
    );
  }
}
