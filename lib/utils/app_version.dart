// 🎯 Dart imports:
import 'dart:convert' show json;
import 'dart:io' show Platform;

// 📦 Package imports:
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' show launchUrl;

// 🌎 Project imports:
import '../shared/custom_confirm.dart';
import 'html/parser/parser.dart';
import 'info_plus/package_info_plus/package_info.dart' show PackageInfo;

// 참조
// https://github.com/timtraversy/new_version/blob/master/lib/new_version.dart
class VersionStatus {
  final String localVersion;
  final String storeVersion;
  final String appStoreLink;

  VersionStatus._({
    required this.localVersion,
    required this.storeVersion,
    required this.appStoreLink,
  });

  bool get canUpdate {
    final List<int> local = localVersion.split('.').map(int.parse).toList();
    final List<int> store = storeVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < store.length; i++) {
      if (store[i] > local[i]) {
        return true;
      }

      if (local[i] > store[i]) {
        return false;
      }
    }

    return false;
  }

  void printVersion() {
    print('=============== Version Status ===============');
    print('localVersion: $localVersion');
    print('storeVersion: $storeVersion');
    print('appStoreLink: $appStoreLink');
    print('canUpdate: $canUpdate');
    print('====== Version Status From. updatealert ======');
  }
}

class AppVersionValidator {
  final String? iOSId;
  final String? androidId;
  AppVersionValidator({
    this.androidId,
    this.iOSId,
  });

  Future<VersionStatus?> _getVersionStatus() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isIOS) {
      return _getiOSStoreVersion(packageInfo);
    } else if (Platform.isAndroid) {
      return _getAndroidStoreVersion(packageInfo);
    }
    print(
        'The target platform "${Platform.operatingSystem}" is not yet supported by this package.');
    return null;
  }

  String _getCleanVersion(String version) =>
      RegExp(r'\d+\.\d+\.\d+').stringMatch(version) ?? '0.0.0';

  Future<VersionStatus?> _getiOSStoreVersion(PackageInfo packageInfo) async {
    String storeVersion = packageInfo.version;
    try {
      final String id = iOSId ?? packageInfo.packageName;
      final Map<String, String> parameters = {'bundleId': id};
      final Uri uri = Uri.https('itunes.apple.com', '/lookup', parameters);
      final http.Response response = await http.get(uri);
      if (response.statusCode != 200) {
        print('Failed to query iOS App Store');
        return null;
      }

      final dynamic jsonObj = json.decode(response.body);
      final List results = jsonObj['results'];
      if (results.isEmpty) {
        print('Can\'t find an app in the App Store with the id: $id');
        return null;
      }
      storeVersion = jsonObj['results'][0]['version'];
      return VersionStatus._(
        localVersion: _getCleanVersion(packageInfo.version),
        storeVersion: _getCleanVersion(storeVersion),
        appStoreLink: jsonObj['results'][0]['trackViewUrl'],
      );
    } catch (e) {
      print('Get ios Version Error!!!');
      print(e);
      return VersionStatus._(
          localVersion: storeVersion,
          storeVersion: storeVersion,
          appStoreLink: '');
    }
  }

  Future<VersionStatus?> _getAndroidStoreVersion(
      PackageInfo packageInfo) async {
    String storeVersion = packageInfo.version;
    try {
      final String id = androidId ?? packageInfo.packageName;
      final Uri uri =
          Uri.https('play.google.com', '/store/apps/details', {'id': id});
      final http.Response response = await http.get(uri);
      if (response.statusCode != 200) {
        print('Can\'t find an app in the Play Store with the id: $id');
        return null;
      }

      final Document document = htmlParse(response.body);
      final List<Element> scriptElements =
          document.getElementsByTagName('script');
      final Element infoScriptElement = scriptElements.firstWhere(
        (Element elm) => elm.text.contains("key: 'ds:5'"),
      );
      final String param = infoScriptElement.text
          .substring(20, infoScriptElement.text.length - 2)
          .replaceAll('key:', '"key":')
          .replaceAll('hash:', '"hash":')
          .replaceAll('data:', '"data":')
          .replaceAll('sideChannel:', '"sideChannel":')
          .replaceAll('\'', '"');
      final dynamic parsed = json.decode(param);
      final dynamic data = parsed['data'];

      storeVersion = data[1][2][140][0][0][0];
      return VersionStatus._(
        localVersion: _getCleanVersion(packageInfo.version),
        storeVersion: _getCleanVersion(storeVersion),
        appStoreLink: uri.toString(),
      );
    } catch (e) {
      print('Get Android Version Error!!!');
      print(e);
      return VersionStatus._(
          localVersion: storeVersion,
          storeVersion: storeVersion,
          appStoreLink: '');
    }
  }

  Future<void> _launchAppStore(String appStoreLink) async {
    if (Platform.isIOS) {
      final Uri url = Uri.parse('https://bside.page.link/download');
      if (!await launchUrl(url)) throw 'Could not launch $url';
    } else if (Platform.isAndroid) {
      final Uri url = Uri.parse(appStoreLink);
      if (!await launchUrl(url)) throw 'Could not launch $url';
    }
  }
}

dynamic compareAppVersion() async {
  final AppVersionValidator versionValidator = AppVersionValidator();
  final VersionStatus? version = await versionValidator._getVersionStatus();
  if (version != null) {
    version.printVersion();
    if (version.canUpdate) {
      customWindowConfirm('새로운 앱 버전이 있습니다.', '업데이트 하러가기', () {
        versionValidator._launchAppStore(version.appStoreLink);
      });
    }
  }
}
