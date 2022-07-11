// 🎯 Dart imports:
import 'dart:convert' show jsonEncode;

// 📦 Package imports:
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

// 🌎 Project imports:
import 'vote/vote.controller.dart';

class MainService extends GetConnect {
  String baseURL = 'https://api.bside.ai/crashlytics';
  VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());
  String getURL(String url) => baseURL + url;

  Future<Response> logAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var data = {
      'app_name': packageInfo.appName,
      'build_number': packageInfo.buildNumber,
      'app_version': packageInfo.version,
      'device_name': await voteCtrl.deviceInfo(),
    };
    if (kDebugMode) {
      print(data);
    }
    return put(getURL('/app_version'), jsonEncode(data));
  }

  Future<Response> reportUncaughtError(Object error, StackTrace trace) {
    return post(
        getURL('/error_handler'),
        jsonEncode({
          'error': error.toString(),
          'trace': trace.toString(),
        }));
  }
}
