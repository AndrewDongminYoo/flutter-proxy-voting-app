// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get_connect/connect.dart' show GetConnect;

// 🌎 Project imports:
import '../utils/channel.dart';
import 'mts.dart';

class CooconMTSService extends GetConnect {
  // TODO: interface를 구성하여 module별로 각기 다른 비즈니스 로직이 들어갈수 있게 확장 필요
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
        if (module.toString() == 'secCreon') {
          acc = processAcc(acc);
        }
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
                accountType: '1',
                queryCode: '1')
            .post(output);
      }
    } catch (e, t) {
      FirebaseCrashlytics.instance.recordError(e, t);
    } finally {
      await LogoutRequest(module).post(output);
    }
    return output;
  }

  String processAcc(String acc) =>
      '${acc.substring(0, acc.length - 2)}-${acc.substring(acc.length - 2)}';

  loadFunctionVal(String functionName) async {
    String? response = await channel.invokeMethod<String>(functionName.trim());
    return jsonDecode(response!);
  }
}
