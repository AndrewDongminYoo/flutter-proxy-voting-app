// ignore_for_file: avoid_print
// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_connect/connect.dart' show GetConnect;

// 🌎 Project imports:
import '../utils/channel.dart';
import 'mts.dart';

class CooconMTSService extends GetConnect {
  final _db = FirebaseFirestore.instance;

  _handleError(dynamic response, List output, String job) {
    dynamic data = response['Output'];
    String errorCode = data['ErrorCode'];
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

  Future<dynamic> _fetch(dynamic val) async {
    print('===========${val['Job']} ${val['Job'].padLeft(6, ' ')}===========');
    // TODO: ERROR: type '_Uint8ArrayView' is not a subtype of type 'String'
    var response = await channel.invokeMethod('getMTSData', {'data': val});
    return jsonDecode(response);
  }

  _postTo(String userid, dynamic input, List output, String target) async {
    dynamic response = await _fetch(input);
    CollectionReference col = _db.collection('transactions');
    DocumentReference dbRef = col.doc('${userid}_${input['Module']}');
    await dbRef.collection(today()).add(response);
    Set accounts = {};
    var data = _handleError(response, output, input['Job']);
    output.add('=====================================');
    var result = data['Result'];
    if (result == null) output.add('$target 값이 없음.');
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
      dynamic input1 = LoginRequest(
        module,
        idLogin: true,
        username: userID,
        password: password,
        certExpire: '',
      ).json;
      await _fetch(input1);
      dynamic input2 = AccountAll(
        module,
        password: passNum,
        queryCode: '',
      ).json;
      await _postTo(userID, input2, output, '전계좌조회');
      dynamic input3 = AccountStocks(
        module,
      ).json;
      var accounts = await _postTo(userID, input3, output, '증권보유계좌조회');
      if (accounts != null) {
        for (var acc in accounts) {
          dynamic input4 = AccountDetail(
            module,
            accountNum: acc,
            accountPin: passNum,
            queryCode: code,
            showISO: unit,
          ).json;
          await _postTo(userID, input4, output, '계좌상세조회');
        }
        for (var acc in accounts) {
          if (module == 'secCreon') {
            acc = acc.substring(0, acc.length - 2) +
                '-' +
                acc.substring(acc.length - 2);
          }
          dynamic input5 = AccountTransaction(
            module,
            accountNum: acc,
            accountPin: passNum,
            accountExt: '',
            accountType: '1',
            queryCode: '1',
          ).json;
          await _postTo(userID, input5, output, '거래내역조회');
        }
      }
    } catch (e, t) {
      print('===== ERROR =====');
      print(e.toString());
      print(t.toString());
    } finally {
      await _fetch(LogoutRequest(
        module,
      ).json);
    }
    return output;
  }

  loadFunctionVal(String functionName) async {
    var response = await channel.invokeMethod(functionName.trim());
    return jsonDecode(response);
  }
}
