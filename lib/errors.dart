// 🎯 Dart imports:
import 'dart:convert' show jsonEncode;

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'utils/package_info.dart';
import 'vote/vote.controller.dart';

class MainService extends GetConnect {
  String baseURL = 'https://api.bside.ai/crashlytics';
  VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());
  String getURL(String url) => baseURL + url;

  Future<Response> logAppVersion(int uid, String company) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    String appName = packageInfo.appName;
    String buildNumber = packageInfo.buildNumber;
    String deviceName = await voteCtrl.deviceInfo();
    return put(
        getURL('/app_version'),
        jsonEncode({
          'app_name': appName,
          'build_number': buildNumber,
          'app_version': appVersion,
          'device_name': deviceName,
        }));
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
