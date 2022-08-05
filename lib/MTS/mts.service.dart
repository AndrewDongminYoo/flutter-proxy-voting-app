// ignore_for_file: avoid_print
// 🐦 Flutter imports:
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get_connect/connect.dart';
import 'package:intl/intl.dart';

class CooconMTSService extends GetConnect {
  MethodChannel platform = const MethodChannel('bside.native.dev/info');
  DateFormat formatter = DateFormat('YYYYMMDD');
  commonBody(String action) => {'Class': '증권서비스', 'Job': action};

  makeSignInData(
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

  accountInquiry(
    String module,
  ) {
    return {
      'Module': module,
      ...commonBody('증권보유계좌조회'),
      'Input': {},
    };
  }

  accountInquiryAll(
    String module,
    String password, {
    String code = '',
  }) {
    return {
      'Module': module,
      ...commonBody('전계좌조회'),
      'Input': {
        '사용자비밀번호': password, // 키움 증권만 사용
        '조회구분': code, // "S": 키움 간편조회, 메리츠 전체계좌, 삼성 계좌잔고
      }, // 없음: 키움 일반조회, 메리츠 계좌평가, 삼성 종합잔고평가
    }; // "D": 대신,크레온 종합번호+계좌번호, 없음: 일반조회
  }

  accountInquiryDetails(
    String module,
    String accountNum,
    String password, {
    String code = '',
    String unit = '',
  }) {
    return {
      'Module': module,
      ...commonBody('계좌상세조회'), // 상세잔고조회
      'Input': {
        '계좌번호': accountNum,
        '계좌비밀번호': password,
        '조회구분': code, // 삼성 "K": 외화만, 없음: 기본조회
        '통화코드출력여부': unit, // KB "2": 통화코드,현재가,매입평균가 미출력, 없음: 모두출력
      },
    };
  }

  accountInquiryTransactions(
    String module,
    String accountNum,
    String password, {
    String type = '',
    String code = '',
    String start = '',
    String end = '',
    String ext = '',
  }) {
    if (!['000', '001', '002', ''].contains(ext)) return;
    if (!['01', '02', '05', ''].contains(type)) return;
    if (!['1', '2', 'D', ''].contains(code)) return;
    if (start.isEmpty) start = today();
    if (end.isEmpty) end = oneMonthAgo(start);
    return {
      'Module': module,
      ...commonBody('전상품조회'), // 상세거래내역조회
      'Input': {
        '상품구분': '', // "01"위탁 "02"펀드 "05"CMA
        '조회구분': code, // "1"종합거래내역 "2"입출금내역 "D"종합거래내역 없음:간단히
        '계좌번호': accountNum,
        '계좌비밀번호': password, // 입력 안해도 되지만 안하면 구매종목 안나옴.
        '계좌번호확장': ext, // 하나증권만 사용("000"~"002")
        '조회시작일': start, // YYYYMMDD
        '조회종료일': end, // YYYYMMDD
      },
    };
  }

  logOut(String module) {
    return {
      'Module': module,
      ...commonBody('로그아웃'),
      'Input': {},
    };
  }

  Future<dynamic> fetch(dynamic input) async {
    var data = {'data': input};
    var response = await platform.invokeMethod('getMTSData', data);
    String cls = input['Class'];
    String job = input['Job'];
    print('===========$cls ${job.padLeft(6, ' ')}===========');
    print(response);
    return jsonDecode(response);
  }

  today() {
    DateTime dateTime = DateTime.now();
    return formatter.format(dateTime);
  }

  oneMonthAgo(String dDay) {
    final now = DateTime.tryParse(dDay) ?? DateTime.now();
    Duration duration = const Duration(days: 30);
    DateTime monthAgo = now.subtract(duration);
    return formatter.format(monthAgo);
  }

  numberWithComma(String number) {
    var num = int.tryParse(number.trim());
    var comma = NumberFormat.decimalPattern();
    if (num == null) return '';
    return comma.format(num);
  }

  fetchMTSData({
    required String module,
    required String username,
    required String password,
    String start = '',
    String end = '',
    String code = '',
    String unit = '',
    required String passNum,
  }) async {
    print('mts.service.dart shoot data');
    dynamic input1 = makeSignInData(module, username, password);
    dynamic resp1 = await fetch(input1);
    if (resp1['Output']['ErrorCode'] != '00000000') {
      print('아이디와 비밀번호를 확인해주세요.');
      return;
    }
    String name = resp1['Output']['Result']['사용자이름'];
    print('HELLO, $name.');
    dynamic input2 = accountInquiryAll(module, passNum);
    dynamic resp2 = await fetch(input2);
    List<dynamic> accountPool = resp2['Output']['Result']['전계좌조회'];
    for (int i = 0; i < accountPool.length; i++) {
      print('-----------------------');
      String accountNum = accountPool[i]['계좌번호'];
      print('계좌번호 : $accountNum');
      print("출금가능금액 : ${numberWithComma(accountPool[i]['출금가능금액'] ?? 0)}");
      print("총자산 : ${numberWithComma(accountPool[i]['총자산'] ?? 0)}");
      dynamic input3 = accountInquiryDetails(module, accountNum, passNum,
          code: code, unit: unit);
      dynamic resp3 = await fetch(input3);
      List<dynamic> transactions = resp3['Output']['Result']['계좌상세조회'];
      for (int j = 0; j < transactions.length; j++) {
        dynamic transaction = transactions[j];
        print('======================');
        print('상품명: ${transaction['상품명'] ?? 'none'}');
        print('상품_종목명: ${transaction['상품_종목명'] ?? 'none'}');
        print('매입금액: ${numberWithComma(transaction['매입금액'] ?? 0)}');
        print('평가금액: ${numberWithComma(transaction['평가금액'] ?? 0)}');
        print('수량: ${transaction['수량'] ?? 0}');
        print('평균매입가: ${numberWithComma(transaction['평균매입가'] ?? 0)}');
        print('현재가: ${numberWithComma(transaction['현재가'] ?? 0)}');
        print('평가손익: ${numberWithComma(transaction['평가손익'] ?? 0)}');
        print('수익률: ${transaction['수익률'] ?? 0}%');
      }
    }
    await fetch(logOut(module));
  }
}
