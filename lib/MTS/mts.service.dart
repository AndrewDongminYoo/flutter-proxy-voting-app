// 🎯 Dart imports:

// 📦 Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import '../utils/global_channel.dart';
import 'mts.dart';

class CooconMTSService extends GetConnect {
  fetchMTSData({
    required CustomModule module,
    required String userId, // "ydm2790"
    required String username, // "유동민"
    required String password,
    required String passNum,
    required bool idLogin,
    String start = '',
    String end = '',
    String code = '',
    String unit = '',
    String certExpire = '',
    String certUsername = '',
    String certPassword = '',
  }) async {
    try {
      String name = await LoginRequest(
        module,
        idLogin: idLogin,
        userId: userId,
        password: password,
        certExpire: certExpire,
        certPassword: certPassword,
        certUsername: certUsername,
      ).post(username);
      username = name;
      await AccountAll(
        module,
        password: passNum,
      ).post(username);
      Set<String> accounts = await AccountStocks(module).post(username);
      for (String acc in accounts) {
        await AccountDetail(module,
                accountNum: acc,
                accountPin: passNum,
                queryCode: code,
                showISO: unit)
            .post(username);
      }
      for (String acc in accounts) {
        await AccountTransaction(module,
                accountNum: acc,
                accountPin: passNum,
                accountExt: '',
                accountType: '01',
                queryCode: '1')
            .post(username);
      }
    } catch (err, trc) {
      FirebaseCrashlytics.instance.recordError(err, trc);
    } finally {
      await LogoutRequest(module).post(username);
    }
  }

  Future<String?> getTwelveDigits() async {
    try {
      return await channel.invokeMethod('getTwelveDigits');
    } catch (e) {
      e.printError();
      return null;
    }
  }

  Future<bool> checkImport() async {
    return await channel.invokeMethod('checkIfImported');
  }

  Future<List<RKSWCertItem>> loadCertificationList() async {
    List<RKSWCertItem> list = [];
    List? response = await channel.invokeListMethod('loadCertList');
    print(response);
    if (response != null) {
      for (dynamic json in response) {
        RKSWCertItem item = RKSWCertItem.from(json);
        list.add(item);
      }
    }
    return list;
  }

  emptyCerts() async {
    await channel.invokeMethod('emptyCertifications');
  }

  void changePasswordOfCert(
      String oldPassword, String newPassword, String certName) async {
    await channel.invokeMethod('changePassword', {
      'newPassword': newPassword,
      'oldPassword': oldPassword,
      'certName': certName,
    });
  }
}
