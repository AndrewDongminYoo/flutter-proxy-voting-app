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
    required this.utsname,
  });

  final String? name;

  final String? systemName;

  final String? systemVersion;

  final String? model;

  final String? localizedModel;

  final String? identifierForVendor;

  final bool isPhysicalDevice;

  final IosUtsname utsname;

  static IosDeviceInfo fromMap(Map<String, dynamic> map) {
    return IosDeviceInfo(
      name: map['name'],
      systemName: map['systemName'],
      systemVersion: map['systemVersion'],
      model: map['model'],
      localizedModel: map['localizedModel'],
      identifierForVendor: map['identifierForVendor'],
      isPhysicalDevice: map['isPhysicalDevice'] == 'true',
      utsname:
          IosUtsname._fromMap(map['utsname']?.cast<String, dynamic>() ?? {}),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'model': model,
      'systemName': systemName,
      'utsname': utsname._toMap(),
      'systemVersion': systemVersion,
      'localizedModel': localizedModel,
      'identifierForVendor': identifierForVendor,
      'isPhysicalDevice': isPhysicalDevice.toString(),
    };
  }
}

class IosUtsname {
  const IosUtsname._({
    this.sysname,
    this.nodename,
    this.release,
    this.version,
    this.machine,
  });

  final String? sysname;

  final String? nodename;

  final String? release;

  final String? version;

  final String? machine;

  static IosUtsname _fromMap(Map<String, dynamic> map) {
    return IosUtsname._(
      sysname: map['sysname'],
      nodename: map['nodename'],
      release: map['release'],
      version: map['version'],
      machine: map['machine'],
    );
  }

  Map<String, dynamic> _toMap() {
    return {
      'release': release,
      'version': version,
      'machine': machine,
      'sysname': sysname,
      'nodename': nodename,
    };
  }
}
