// 🌎 Project imports:
import 'base_device_info.dart';

class IosDeviceInfo implements BaseDeviceInfo {
  const IosDeviceInfo({
    this.name,
    this.systemName,
    this.systemVersion,
    this.model,
    this.localizedModel,
    this.identifierForVendor,
    required this.isPhysicalDevice,
  });

  final String? name;

  final String? systemName;

  final String? systemVersion;

  final String? model;

  final String? localizedModel;

  final String? identifierForVendor;

  final bool isPhysicalDevice;

  static IosDeviceInfo fromMap(Map<String, dynamic> map) {
    return IosDeviceInfo(
      name: map['name'],
      systemName: map['systemName'],
      systemVersion: map['systemVersion'],
      model: map['model'],
      localizedModel: map['localizedModel'],
      identifierForVendor: map['identifierForVendor'],
      isPhysicalDevice: map['isPhysicalDevice'] == 'true',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'model': model,
      'systemName': systemName,
      'systemVersion': systemVersion,
      'localizedModel': localizedModel,
      'identifierForVendor': identifierForVendor,
      'isPhysicalDevice': isPhysicalDevice.toString(),
    };
  }
}
