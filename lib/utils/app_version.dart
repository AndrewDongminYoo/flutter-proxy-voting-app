// 🎯 Dart imports:
import 'dart:convert' show json;
import 'dart:io' show Platform;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

// 🌎 Project imports:
import '../shared/custom_confirm.dart';

// 참조
// https://github.com/timtraversy/new_version/blob/master/lib/new_version.dart
class VersionStatus {
  final String localVersion;
  final String storeVersion;
  final String appStoreLink;
  final String? releaseNotes;

  VersionStatus._({
    required this.localVersion,
    required this.storeVersion,
    required this.appStoreLink,
    this.releaseNotes,
  });

  bool get canUpdate {
    final local = localVersion.split('.').map(int.parse).toList();
    final store = storeVersion.split('.').map(int.parse).toList();

    for (var i = 0; i < store.length; i++) {
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
    debugPrint('===== Version Status =====');
    debugPrint('localVersion: $localVersion');
    debugPrint('storeVersion: $storeVersion');
    debugPrint('appStoreLink: $appStoreLink');
    debugPrint('canUpdate: $canUpdate');
    debugPrint('===== Version Status  From. updatealert =====');
  }
}

class AppVersionValidator {
  final String? iOSId;
  final String? androidId;
  final String? iOSAppStoreCountry;
  AppVersionValidator({
    this.androidId,
    this.iOSId,
    this.iOSAppStoreCountry,
  });

  Future<VersionStatus?> _getVersionStatus() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isIOS) {
      return _getiOSStoreVersion(packageInfo);
    } else if (Platform.isAndroid) {
      return _getAndroidStoreVersion(packageInfo);
    }
    debugPrint(
        'The target platform "${Platform.operatingSystem}" is not yet supported by this package.');
    return null;
  }

  String _getCleanVersion(String version) =>
      RegExp(r'\d+\.\d+\.\d+').stringMatch(version) ?? '0.0.0';

  Future<VersionStatus?> _getiOSStoreVersion(PackageInfo packageInfo) async {
    final id = iOSId ?? packageInfo.packageName;
    final parameters = {'bundleId': id};
    if (iOSAppStoreCountry != null) {
      parameters.addAll({'country': iOSAppStoreCountry!});
    }
    var uri = Uri.https('itunes.apple.com', '/lookup', parameters);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('Failed to query iOS App Store');
      return null;
    }
    final jsonObj = json.decode(response.body);
    final List results = jsonObj['results'];
    if (results.isEmpty) {
      debugPrint('Can\'t find an app in the App Store with the id: $id');
      return null;
    }
    return VersionStatus._(
      // localVersion: '1.3.8',
      localVersion: _getCleanVersion(packageInfo.version),
      storeVersion:
          // _getCleanVersion(forceAppVersion ?? jsonObj['results'][0]['version']),
          _getCleanVersion(jsonObj['results'][0]['version']),
      appStoreLink: jsonObj['results'][0]['trackViewUrl'],
      releaseNotes: jsonObj['results'][0]['releaseNotes'],
    );
  }

  Future<VersionStatus?> _getAndroidStoreVersion(
      PackageInfo packageInfo) async {
    final id = androidId ?? packageInfo.packageName;
    final uri = Uri.https(
        'play.google.com', '/store/apps/details', {'id': id, 'hl': 'kr'});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('Can\'t find an app in the Play Store with the id: $id');
      return null;
    }

    final document = parse(response.body);

    String storeVersion = '0.0.0';
    String? releaseNotes;

    final additionalInfoElements = document.getElementsByClassName('hAyfc');
    if (additionalInfoElements.isNotEmpty) {
      final versionElement = additionalInfoElements.firstWhere(
        (elm) => elm.querySelector('.BgcNfc')!.text == 'Current Version',
      );
      storeVersion = versionElement.querySelector('.htlgb')!.text;

      final sectionElements = document.getElementsByClassName('W4P4ne');
      final releaseNotesElement = sectionElements.firstWhereOrNull(
        (elm) => elm.querySelector('.wSaTQd')!.text == 'What\'s New',
      );
      releaseNotes = releaseNotesElement
          ?.querySelector('.PHBdkd')
          ?.querySelector('.DWPxHb')
          ?.text;
    } else {
      final scriptElements = document.getElementsByTagName('script');
      final infoScriptElement = scriptElements.firstWhere(
        (elm) => elm.text.contains('key: \'ds:4\''),
      );

      final param = infoScriptElement.text
          .substring(20, infoScriptElement.text.length - 2)
          .replaceAll('key:', '"key":')
          .replaceAll('hash:', '"hash":')
          .replaceAll('data:', '"data":')
          .replaceAll('sideChannel:', '"sideChannel":')
          .replaceAll('\'', '"');
      final parsed = json.decode(param);
      final data = parsed['data'];

      storeVersion = data[1][2][140][0][0][0];
      releaseNotes = data[1][2][144][1][1];
    }

    return VersionStatus._(
      // localVersion: '1.3.8',
      localVersion: _getCleanVersion(packageInfo.version),
      // storeVersion: _getCleanVersion(forceAppVersion ?? storeVersion),
      storeVersion: _getCleanVersion(storeVersion),
      appStoreLink: uri.toString(),
      releaseNotes: releaseNotes,
    );
  }

  Future<void> _launchAppStore(String appStoreLink) async {
    final Uri url = Uri.parse('https://bside.page.link/download');
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }
}

compareAppVersion() async {
  if (!Platform.isAndroid) {
    final versionValidator = AppVersionValidator();
    final version = await versionValidator._getVersionStatus();
    version!.printVersion();
    if (version.canUpdate) {
      customWindowConfirm('새로운 앱 버전이 있습니다.', '업데이트 하러가기', () {
        versionValidator._launchAppStore(version.appStoreLink);
      });
    }
  }
}
