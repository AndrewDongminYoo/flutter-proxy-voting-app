// ignore_for_file: avoid_print
// 🐦 Flutter imports:
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get_connect/connect.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

class CooconMTSService extends GetConnect {
  MethodChannel platform = const MethodChannel('bside.native.dev/info');
  FirebaseFirestore db = FirebaseFirestore.instance;
  commonBody(String action) => {'Class': '증권서비스', 'Job': action};

  login(
    String module,
    String username,
    String password, {
    bool idLogin = true,
  }) {
    return {
      'Module': module,
      ...commonBody('로그인'),
      'Input': {
        '로그인방식': idLogin ? 'ID' : 'CERT', // CERT: 인증서, ID: 아이디
        '사용자아이디': username, // required // IBK, KTB 필수 입력
        '사용자비밀번호': password, // required // IBK, KTB 필수 입력
        '인증서': {}, // 있을 경우 "이름", "만료일자", "비밀번호" 키로 입력
      },
    };
  }

  queryStocks(
    String module,
  ) {
    return {
      ...commonBody('증권보유계좌조회'),
      'Module': module,
      'Input': {},
    };
  }

  queryAll(
    String module,
    String password, {
    String code = '',
  }) {
    return {
      ...commonBody('전계좌조회'),
      'Module': module,
      'Input': {
        '사용자비밀번호': password, // 키움 증권만 사용
        '조회구분': code, // "S": 키움 간편조회, 메리츠 전체계좌, 삼성 계좌잔고
      }, // 없음: 키움 일반조회, 메리츠 계좌평가, 삼성 종합잔고평가
    }; // "D": 대신,크레온 종합번호+계좌번호, 없음: 일반조회
  }

  queryDetail(
    String module,
    String accountNum,
    String password,
    String code,
    String unit,
  ) {
    return {
      ...commonBody('계좌상세조회'), // 상세잔고조회
      'Module': module,
      'Input': {
        '계좌번호': accountNum,
        '계좌비밀번호': password, // 입력 안해도 되지만 안하면 구매종목 안나옴.
        '조회구분': code, // 삼성 "K": 외화만, 없음: 기본조회
        '통화코드출력여부': unit, // KB "2": 통화코드,현재가,매입평균가 미출력, 없음: 모두출력
      },
    };
  }

  queryTrades(
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
    if (start.isEmpty) start = three(start);
    if (end.isEmpty) end = today();
    return {
      ...commonBody('거래내역조회'), // 상세거래내역조회
      'Module': module,
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

  logOut(String module) {
    return {
      ...commonBody('로그아웃'),
      'Module': module,
      'Input': {},
    };
  }

  Future<dynamic> fetch(dynamic val) async {
    print('===========${val['Job']} ${val['Job'].padLeft(6, ' ')}===========');
    var response = await platform.invokeMethod('getMTSData', {'data': val});
    return jsonDecode(response);
  }

  postTo(String userid, dynamic input, List output, String target) async {
    dynamic response = await fetch(input);
    print(response);
    List accounts = [];
    if (response['Output']['ErrorCode'] != '00000000') {
      output.add('${input["Job"]}: "${response['Output']['ErrorMessage']}"');
      return;
    }
    output.add('=====================================');
    var result = response['Output']['Result'];
    var dbRef = db.collection('transactions').doc(userid);
    await dbRef.collection(today()).add(result);
    if (result == null) output.add('$target 값이 없음.');
    if (result is String && result.isEmpty) return;
    dynamic data = result[target];
    switch (data.runtimeType) {
      case List:
        data.forEach((element) {
          element.forEach((String key, value) {
            if (key == '계좌번호') {
              accounts.add(value);
              output.add('$key: ${hypen(value)}');
            } else if (key.contains('일자')) {
              output.add('$key: ${dayOf(value)}');
            } else {
              output.add('$key: ${check(value)}');
            }
          });
          output.add('-------------------------------------');
        });
        return accounts;
      case Map:
        data.forEach((key, value) {
          output.add('$key: ${check(value)}');
        });
        return data;
    }
  }

  fetchMTSData(
      {required String module,
      required String username,
      required String userID,
      required String password,
      String start = '',
      String end = '',
      String code = '',
      String unit = '',
      required String passNum}) async {
    try {
      List<String> output = [];
      dynamic input1 = login(module, username, password);
      await fetch(input1);
      dynamic input2 = queryAll(module, passNum);
      await postTo(userID, input2, output, '전계좌조회');
      dynamic input3 = queryStocks(module);
      var accounts = await postTo(userID, input3, output, '증권보유계좌조회');
      if (accounts != null) {
        for (var accountNum in accounts) {
          dynamic input4 = queryDetail(module, accountNum, passNum, code, unit);
          await postTo(userID, input4, output, '계좌상세조회');
        }
        for (var accountNum in accounts) {
          dynamic input5 = queryTrades(module, accountNum, passNum);
          await postTo(userID, input5, output, '거래내역조회');
        }
      }
      return output;
    } catch (e, t) {
      print(e.toString());
      print(t.toString());
    } finally {
      await fetch(logOut(module));
    }
  }
}

DateFormat formatter = DateFormat('yyyyMMdd');
DateFormat formattor = DateFormat('yyyy-MM-dd');

hypen(String num) =>
    '${num.substring(0, 3)}-${num.substring(3, 7)}-${num.substring(7)}';

String dayOf(String day) {
  DateTime date = DateTime.parse(day);
  return formattor.format(date);
}

String today() {
  DateTime dateTime = DateTime.now();
  return formatter.format(dateTime);
}

String three(String dDay) {
  final now = DateTime.tryParse(dDay) ?? DateTime.now();
  Duration duration = const Duration(days: 92); // 3개월
  DateTime monthAgo = now.subtract(duration);
  return formatter.format(monthAgo);
}

dynamic check(dynamic value) {
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
