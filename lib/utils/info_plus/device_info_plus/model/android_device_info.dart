// 🌎 Project imports:
import 'base_device_info.dart';

class AndroidDeviceInfo implements BaseDeviceInfo {
  AndroidDeviceInfo({
    required this.version,
    this.board,
    this.bootloader,
    this.brand,
    this.device,
    this.display,
    this.fingerprint,
    this.hardware,
    this.host,
    this.id,
    this.manufacturer,
    this.model,
    this.product,
    required List<String?> supported32BitAbis,
    required List<String?> supported64BitAbis,
    required List<String?> supportedAbis,
    this.tags,
    this.type,
    this.isPhysicalDevice,
    this.androidId,
    required List<String?> systemFeatures,
  })  : supported32BitAbis = List<String?>.unmodifiable(supported32BitAbis),
        supported64BitAbis = List<String?>.unmodifiable(supported64BitAbis),
        supportedAbis = List<String?>.unmodifiable(supportedAbis),
        systemFeatures = List<String?>.unmodifiable(systemFeatures);

  final AndroidBuildVersion version;

  final String? board;

  final String? bootloader;

  final String? brand;

  final String? device;

  final String? display;

  final String? fingerprint;

  final String? hardware;

  final String? host;

  final String? id;

  final String? manufacturer;

  final String? model;

  final String? product;

  final List<String?> supported32BitAbis;

  final List<String?> supported64BitAbis;

  final List<String?> supportedAbis;

  final String? tags;

  final String? type;

  final bool? isPhysicalDevice;

  final String? androidId;

  final List<String?> systemFeatures;

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'host': host,
      'tags': tags,
      'type': type,
      'model': model,
      'board': board,
      'brand': brand,
      'device': device,
      'product': product,
      'display': display,
      'hardware': hardware,
      'androidId': androidId,
      'bootloader': bootloader,
      'version': version.toMap(),
      'fingerprint': fingerprint,
      'manufacturer': manufacturer,
      'supportedAbis': supportedAbis,
      'systemFeatures': systemFeatures,
      'isPhysicalDevice': isPhysicalDevice,
      'supported32BitAbis': supported32BitAbis,
      'supported64BitAbis': supported64BitAbis,
    };
  }

  static AndroidDeviceInfo fromMap(Map<String, dynamic> map) {
    return AndroidDeviceInfo(
      version: AndroidBuildVersion._fromMap(
          map['version']?.cast<String, dynamic>() ?? {}),
      board: map['board'],
      bootloader: map['bootloader'],
      brand: map['brand'],
      device: map['device'],
      display: map['display'],
      fingerprint: map['fingerprint'],
      hardware: map['hardware'],
      host: map['host'],
      id: map['id'],
      manufacturer: map['manufacturer'],
      model: map['model'],
      product: map['product'],
      supported32BitAbis: _fromList(map['supported32BitAbis'] ?? []),
      supported64BitAbis: _fromList(map['supported64BitAbis'] ?? []),
      supportedAbis: _fromList(map['supportedAbis'] ?? []),
      tags: map['tags'],
      type: map['type'],
      isPhysicalDevice: map['isPhysicalDevice'],
      androidId: map['androidId'],
      systemFeatures: _fromList(map['systemFeatures'] ?? []),
    );
  }

  static List<String?> _fromList(dynamic message) {
    final List<dynamic> list = message;
    return List<String?>.from(list);
  }
}

class AndroidBuildVersion {
  const AndroidBuildVersion._({
    this.baseOS,
    this.codename,
    this.incremental,
    this.previewSdkInt,
    this.release,
    this.sdkInt,
    this.securityPatch,
  });

  final String? baseOS;

  final String? codename;

  final String? incremental;

  final int? previewSdkInt;

  final String? release;

  final int? sdkInt;

  final String? securityPatch;

  Map<String, dynamic> toMap() {
    return {
      'baseOS': baseOS,
      'sdkInt': sdkInt,
      'release': release,
      'codename': codename,
      'incremental': incremental,
      'previewSdkInt': previewSdkInt,
      'securityPatch': securityPatch,
    };
  }

  static AndroidBuildVersion _fromMap(Map<String, dynamic> map) {
    return AndroidBuildVersion._(
      baseOS: map['baseOS'],
      codename: map['codename'],
      incremental: map['incremental'],
      previewSdkInt: map['previewSdkInt'],
      release: map['release'],
      sdkInt: map['sdkInt'],
      securityPatch: map['securityPatch'],
    );
  }
}
