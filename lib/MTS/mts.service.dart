// ignore_for_file: avoid_print
// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_connect/connect.dart' show GetConnect;
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

// 🌎 Project imports:
import 'mts.data.dart' show errorMsg;
import '../utils/method_channel.dart';

class CooconMTSService extends GetConnect {
  final _db = FirebaseFirestore.instance;

  _commonBody(
    String module,
    String action,
  ) =>
      {
        'Class': '증권서비스',
        'Module': module,
        'Job': action,
        'Input': {},
      };

  _login(
    String module,
    String username,
    String password, {
    bool idLogin = true,
  }) {
    return {
      ..._commonBody(module, '로그인'),
      'Input': {
        '로그인방식': idLogin ? 'ID' : 'CERT', // CERT: 인증서, ID: 아이디
        '사용자아이디': username, // required // IBK, KTB 필수 입력
        '사용자비밀번호': password, // required // IBK, KTB 필수 입력
        '인증서': {}, // 있을 경우 "이름", "만료일자", "비밀번호" 키로 입력
      },
    };
  }

  _queryStocks(String module) => _commonBody(module, '증권보유계좌조회');

  _queryAll(
    String module,
    String password, {
    String code = '',
  }) {
    return {
      ..._commonBody(module, '전계좌조회'),
      'Input': {
        '사용자비밀번호': password, // 키움 증권만 사용
        '조회구분': code, // "S": 키움 간편조회, 메리츠 전체계좌, 삼성 계좌잔고
      }, // 없음: 키움 일반조회, 메리츠 계좌평가, 삼성 종합잔고평가
    }; // "D": 대신,크레온 종합번호+계좌번호, 없음: 일반조회
  }

  _queryDetail(
    String module,
    String accountNum,
    String password,
    String code,
    String unit,
  ) {
    return {
      ..._commonBody(module, '계좌상세조회'), // 상세잔고조회
      'Input': {
        '계좌번호': accountNum,
        '계좌비밀번호': password, // 입력 안해도 되지만 안하면 구매종목 안나옴.
        '조회구분': code, // 삼성 "K": 외화만, 없음: 기본조회
        '통화코드출력여부': unit, // KB "2": 통화코드,현재가,매입평균가 미출력, 없음: 모두출력
      },
    };
  }

  _queryTrades(
    String module,
    String accountNum,
    String passNum, {
    String type = '',
    String code = '1',
    String start = '',
    String end = '',
    String ext = '',
  }) {
    if (!['000', '001', '002', ''].contains(ext)) return;
    if (!['01', '02', '05', ''].contains(type)) return;
    if (!['1', '2', 'D'].contains(code)) return;
    if (start.isEmpty) start = _sixAgo(start);
    if (end.isEmpty) end = _today();
    return {
      ..._commonBody(module, '거래내역조회'), // 상세거래내역조회
      'Input': {
        '상품구분': '', // "01"위탁 "02"펀드 "05"CMA
        '조회구분': code, // "1"종합거래내역 "2"입출금내역 "D"종합거래내역 간단히
        '계좌번호': accountNum,
        '계좌비밀번호': passNum,
        '계좌번호확장': ext, // 하나증권만 사용("000"~"002")
        '조회시작일': start, // YYYYMMDD
        '조회종료일': end, // YYYYMMDD
      },
    };
  }

  _logOut(String module) => _commonBody(module, '로그아웃');

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
    await dbRef.collection(_today()).add(response);
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
                  output.add('$key: ${_hypen(value)}');
                }
              } else if (key.contains('일자')) {
                output.add('$key: ${_dayOf(value)}');
              } else if (key.contains('수익률')) {
                output.add('$key: ${_check(value)}%');
              } else if (key != '상품코드') {
                output.add('$key: ${_check(value)}');
              }
            }
          });
          if (output.last != '-') output.add('-');
        }
        return accounts;
      case Map:
        result[target].forEach((key, value) {
          output.add('$key: ${_check(value)}');
        });
        return result[target];
    }
  }

  // TODO: interface를 구성하여 module별로 각기 다른 비즈니스 로직이 들어갈수 있게 확장 필요
  fetchMTSData(
      {required String module,
      required String userID,
      required String password,
      String start = '',
      String end = '',
      String code = '',
      String unit = '',
      required String passNum}) async {
    List<String> output = [];
    try {
      dynamic input1 = _login(module, userID, password);
      await _fetch(input1);
      dynamic input2 = _queryAll(module, passNum);
      await _postTo(userID, input2, output, '전계좌조회');
      dynamic input3 = _queryStocks(module);
      var accounts = await _postTo(userID, input3, output, '증권보유계좌조회');
      if (accounts != null) {
        // for (var acc in accounts) {
        //   dynamic input4 = _queryDetail(module, acc, passNum, code, unit);
        //   await _postTo(userID, input4, output, '계좌상세조회');
        // }
        for (var acc in accounts) {
          if (module == 'secCreon') {
            acc = acc.substring(0, acc.length - 2) +
                '-' +
                acc.substring(acc.length - 2);
          }
          dynamic input5 = _queryTrades(module, acc, passNum);
          await _postTo(userID, input5, output, '거래내역조회');
        }
      }
    } catch (e, t) {
      print('===== ERROR =====');
      print(e.toString());
      print(t.toString());
    } finally {
      await _fetch(_logOut(module));
    }
    return output;
  }

  loadFunctionVal(String functionName) async {
    var response = await channel.invokeMethod(functionName.trim());
    return jsonDecode(response);
  }
}

DateFormat _formatter = DateFormat('yyyyMMdd');
DateFormat _formattor = DateFormat('yyyy-MM-dd');

_hypen(String num) =>
    '${num.substring(0, 3)}-${num.substring(3, 7)}-${num.substring(7)}';

String _dayOf(String day) {
  DateTime date = DateTime.parse(day);
  return _formattor.format(date);
}

String _today() {
  DateTime dateTime = DateTime.now();
  return _formatter.format(dateTime);
}

String _sixAgo(String dDay) {
  final now = DateTime.tryParse(dDay) ?? DateTime.now();
  Duration duration = const Duration(days: 180); // 6개월
  DateTime monthAgo = now.subtract(duration);
  return _formatter.format(monthAgo);
}

dynamic _check(dynamic value) {
  if (value == null) return '0';
  if (value is String) {
    if (value.isEmpty) return '0';
    try {
      var num = double.parse(value.trim());
      var comma = NumberFormat.decimalPattern();
      return comma.format(num);
    } on FormatException {
      return value.trim();
    }
  }
}
