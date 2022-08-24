// ignore_for_file: avoid_print
// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:get/get_connect/connect.dart' show GetConnect;

// 🌎 Project imports:
import '../utils/channel.dart';
import 'mts.dart';

class CooconMTSService extends GetConnect {
  CustomOutput _handleError(
      CustomResponse response, List<String> output, String job) {
    CustomOutput data = response.Output;
    String errorCode = data.ErrorCode;
    switch (errorCode) {
      case ('00000000'):
        print(data.toString());
        return data;
      default:
        String? log = errorMsg[errorCode];
        if (log != null) output.add('$job: "$log"');
        return data;
    }
  }

  _postTo(CustomRequest input, List<String> output, String target) async {
    CustomResponse response = await input.fetch();
    response.fetchDataAndUploadFB();
    Set accounts = <String>{};
    CustomOutput data = _handleError(response, output, input.Job);
    output.add('=====================================');
    dynamic result = data.Result;
    if (result is String && result.isEmpty) return;
    switch (result[target].runtimeType) {
      case List:
        for (Map element in result[target]) {
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
      print('===== ERROR =====');
      print(e.toString());
      print(t.toString());
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
