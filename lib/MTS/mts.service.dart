// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get_connect/connect.dart' show GetConnect;

// 🌎 Project imports:
import '../utils/channel.dart';
import 'mts.dart';

class CooconMTSService extends GetConnect {
  fetchMTSData({
    required CustomModule module,
    required String userID,
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
      await LoginRequest(module,
              idLogin: idLogin,
              username: userID,
              password: password,
              certExpire: certExpire,
              certPassword: certPassword,
              certUsername: certUsername)
          .post();
      await AccountAll(
        module,
        password: passNum,
      ).post();
      Set<String> accounts = await AccountStocks(module).post();
      for (String acc in accounts) {
        await AccountDetail(module,
                accountNum: acc,
                accountPin: passNum,
                queryCode: code,
                showISO: unit)
            .post();
      }
      for (String acc in accounts) {
        await AccountTransaction(module,
                accountNum: acc,
                accountPin: passNum,
                accountExt: '',
                accountType: '01',
                queryCode: '1')
            .post();
      }
    } catch (err, trc) {
      FirebaseCrashlytics.instance.recordError(err, trc);
    } finally {
      await LogoutRequest(module).post();
    }
  }

  loadFunctionVal(String functionName) async {
    String? response = await channel.invokeMethod<String>(functionName.trim());
    return jsonDecode(response!);
  }
}
