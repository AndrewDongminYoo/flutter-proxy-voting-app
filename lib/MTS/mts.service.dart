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
    String start = '',
    String end = '',
    String code = '',
    String unit = '',
    required String passNum,
  }) async {
    List<String> output = [];
    try {
      await LoginRequest(module,
              idLogin: true,
              username: userID,
              password: password,
              certExpire: '')
          .post(output);
      await AccountAll(
        module,
        password: passNum,
      ).post(output);
      var accounts = await AccountStocks(module).post(output);
      for (String acc in accounts) {
        await AccountDetail(module,
                accountNum: acc,
                accountPin: passNum,
                queryCode: code,
                showISO: unit)
            .post(output);
      }
      for (String acc in accounts) {
        await AccountTransaction(module,
                accountNum: acc,
                accountPin: passNum,
                accountExt: '',
                accountType: '01',
                queryCode: '1')
            .post(output);
      }
    } catch (err, trc) {
      FirebaseCrashlytics.instance.recordError(err, trc);
    } finally {
      await LogoutRequest(module).post(output);
    }
    return output;
  }

  loadFunctionVal(String functionName) async {
    String? response = await channel.invokeMethod<String>(functionName.trim());
    return jsonDecode(response!);
  }
}
