// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get_connect/connect.dart' show GetConnect;

// 🌎 Project imports:
import '../utils/channel.dart';
import 'mts.dart';

class CooconMTSService extends GetConnect {
  _postTo(CustomRequest input, List<String> output, String target) async {
    CustomResponse response = await input.fetch();
    await response.fetchDataAndUploadFB();
    Set<String> accounts = {};
    output.add('=====================================');
    Map<String, dynamic> result = response.Output.Result;
    switch (result[target].runtimeType) {
      case List:
        for (Map<String, dynamic> element in result[target]) {
          element.forEach((key, value) {
            if (value.isNotEmpty) {
              if (key == '계좌번호') {
                if (!accounts.contains(value)) {
                  accounts.add(value);
                  output.add('$key: ${hypen(value)}');
                }
              } else if (key.contains('일자')) {
                output.add('$key: ${dayOf(value)}');
              } else if (key.contains('수익률')) {
                output.add('$key: ${check(value)}%');
              } else if (key != '상품코드') {
                output.add('$key: ${check(value)}');
              }
            }
          });
          if (output.last != '-') output.add('-');
        }
        return accounts;
      case Map:
        result[target].forEach((key, value) {
          output.add('$key: ${check(value)}');
        });
        return result[target];
    }
  }

  // TODO: interface를 구성하여 module별로 각기 다른 비즈니스 로직이 들어갈수 있게 확장 필요
  fetchMTSData({
    required String module,
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
      await LoginRequest(
        module,
        idLogin: true,
        username: userID,
        password: password,
        certExpire: '',
      ).post();
      CustomRequest input2 = AccountAll(
        module,
        password: passNum,
        queryCode: '',
      ).json;
      await _postTo(input2, output, '전계좌조회');
      CustomRequest input3 = AccountStocks(
        module,
      ).json;
      List<String> accounts = await _postTo(input3, output, '증권보유계좌조회');
      for (String acc in accounts) {
        CustomRequest input4 = AccountDetail(
          module,
          accountNum: acc,
          accountPin: passNum,
          queryCode: code,
          showISO: unit,
        ).json;
        await _postTo(input4, output, '계좌상세조회');
      }
      for (String acc in accounts) {
        if (module == 'secCreon') {
          acc =
              '${acc.substring(0, acc.length - 2)}-${acc.substring(acc.length - 2)}';
        }
        CustomRequest input5 = AccountTransaction(
          module,
          accountNum: acc,
          accountPin: passNum,
          accountExt: '',
          accountType: '1',
          queryCode: '1',
        ).json;
        await _postTo(input5, output, '거래내역조회');
      }
    } catch (e, t) {
      FirebaseCrashlytics.instance.recordError(e, t);
    } finally {
      await LogoutRequest(
        module,
      ).post();
    }
    return output;
  }

  loadFunctionVal(String functionName) async {
    String? response = await channel.invokeMethod<String>(functionName.trim());
    return jsonDecode(response!);
  }
}
