// 🎯 Dart imports:
import 'dart:convert' show jsonEncode;

// 📦 Package imports:
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

// 🌎 Project imports:
import 'vote/vote.controller.dart';

class MainService extends GetConnect {
  final String _baseURL = 'https://api.bside.ai/crashlytics';
  final VoteController _voteCtrl = VoteController.get();
  String _getURL(String url) => _baseURL + url;

  Future<Response> logAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var data = {
      'app_name': packageInfo.appName,
      'build_number': packageInfo.buildNumber,
      'app_version': packageInfo.version,
      'device_name': await _voteCtrl.deviceInfo(),
    };
    if (kDebugMode) {
      print(data);
    }
    return put(_getURL('/app_version'), jsonEncode(data));
  }

  Future<Response> reportUncaughtError(Object error, StackTrace trace) {
    return post(
        _getURL('/error_handler'),
        jsonEncode({
          'error': error.toString(),
          'trace': trace.toString(),
        }));
  }
}
