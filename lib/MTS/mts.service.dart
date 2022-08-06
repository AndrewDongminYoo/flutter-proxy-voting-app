// ignore_for_file: avoid_print
// 🐦 Flutter imports:
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get_connect/connect.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

class CooconMTSService extends GetConnect {
  MethodChannel platform = const MethodChannel('bside.native.dev/info');
  DateFormat formatter = DateFormat('yyyyMMdd');
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
        '계좌비밀번호': password, // 입력 안해도 되지만 안하면 구매종목 안나옴.
        '조회구분': code, // 삼성 "K": 외화만, 없음: 기본조회
        '통화코드출력여부': unit, // KB "2": 통화코드,현재가,매입평균가 미출력, 없음: 모두출력
      },
    };
  }

  accountInquiryTransactions(
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
    if (start.isEmpty) start = oneMonthAgo(start);
    if (end.isEmpty) end = today();
    return {
      'Module': module,
      ...commonBody('거래내역조회'), // 상세거래내역조회
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
    Duration duration = const Duration(days: 92); // 3개월
    DateTime monthAgo = now.subtract(duration);
    return formatter.format(monthAgo);
  }

  priceNum(String number) {
    var num = double.tryParse(number.trim());
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
    List<String> results = [];
    dynamic resultNullCheck;
    dynamic input0 = makeSignInData(module, username, password);
    dynamic resp0 = await fetch(input0);
    if (resp0['Output']['ErrorCode'] != '00000000') {
      results.add('아이디와 비밀번호를 확인해주세요.');
      return;
    }
    resultNullCheck = resp0['Output']['Result'];
    results.add('HELLO, ${resultNullCheck['사용자이름']}.');
    dynamic input1 = accountInquiryAll(module, passNum);
    dynamic resp1 = await fetch(input1);
    resultNullCheck = resp1['Output']['Result'];
    if (resultNullCheck == null) throw Exception('Log in failed');
    List<dynamic> pool = resultNullCheck['전계좌조회'];
    if (pool.isEmpty) results.add('증권사 계좌 없음.');
    for (int i = 0; i < pool.length; i++) {
      results.add('-----------------------');
      dynamic account = pool[i];
      results.add('계좌번호 : ${account['계좌번호']}');
      results.add("대출금액 : ${priceNum(account['대출금액'] ?? '0')}");
      results.add("출금가능금액 : ${priceNum(account['출금가능금액'] ?? '0')}");
      results.add("예수금 : ${priceNum(account['예수금'] ?? '0')}");
      results.add("총자산 : ${priceNum(account['총자산'] ?? '0')}");
    }
    var input2 = accountInquiry(module);
    dynamic resp2 = await fetch(input2);
    resultNullCheck = resp2['Output']['Result'];
    if (resultNullCheck == null) return;
    List<dynamic> stocks = resultNullCheck['증권보유계좌조회'];
    if (stocks.isEmpty) results.add('증권 보유 계좌 없음.');
    for (int i = 0; i < stocks.length; i++) {
      results.add('........................');
      dynamic stock = stocks[i];
      String accountNum = stock['계좌번호'];
      results.add('계좌번호 : $accountNum');
      results.add("상품코드 : ${stock['상품코드']}");
      results.add("상품명 : ${stock['상품명']}");
      dynamic input3 = accountInquiryDetails(module, accountNum, passNum,
          code: code, unit: unit);
      dynamic resp3 = await fetch(input3);
      resultNullCheck = resp3['Output']['Result'];
      if (resultNullCheck == null) break;
      List<dynamic> accountDetails = resultNullCheck['계좌상세조회'];
      if (accountDetails.isEmpty) results.add('거래내역 없음.');
      for (int j = 0; j < accountDetails.length; j++) {
        dynamic detail = accountDetails[j];
        results.add('======================');
        results.add('상품명: ${detail['상품명'] ?? 'none'}');
        results.add('상품_종목명: ${detail['상품_종목명'] ?? 'none'}');
        results.add('매입금액: ${priceNum(detail['매입금액'] ?? '0')}');
        results.add('평가금액: ${priceNum(detail['평가금액'] ?? '0')}');
        results.add('수량: ${detail['수량'] ?? 0}');
        results.add('평균매입가: ${priceNum(detail['평균매입가'] ?? '0')}');
        results.add('현재가: ${priceNum(detail['현재가'] ?? '0')}');
        results.add('평가손익: ${priceNum(detail['평가손익'] ?? '0')}');
        results.add('수익률: ${detail['수익률'] ?? 0}%');
      }
      dynamic input4 = accountInquiryTransactions(module, accountNum, passNum);
      dynamic resp4 = await fetch(input4);
      resultNullCheck = resp4['Output']['Result'];
      if (resultNullCheck == null) break;
      List<dynamic> transactions = resultNullCheck['거래내역조회'];
      for (int j = 0; j < transactions.length; j++) {
        dynamic action = transactions[j];
        results.add('=+=+=+=+=+=+=+=+=+=+=+');
        results.add("거래일자: ${action['거래일자']}");
        results.add("거래시각: ${action['거래시각']}");
        results.add("거래유형: ${action['거래유형']}");
        results.add("적요: ${action['적요']}");
        results.add("종목명: ${action['종목명']}");
        results.add("거래수량: ${action['거래수량']}");
        results.add("거래금액: ${priceNum(action['거래금액'] ?? '0')}");
        results.add("수수료: ${priceNum(action['수수료'] ?? '0')}");
        results.add("금잔수량: ${action['금잔수량']}");
        results.add("금잔금액: ${priceNum(action['금잔금액'] ?? '0')}");
        results.add("금잔금액2: ${priceNum(action['금잔금액2'] ?? '0')}");
        results.add("통화코드: ${action['통화코드']}");
        results.add("정산금액: ${priceNum(action['정산금액'] ?? '0')}");
        results.add("외화거래금액: ${priceNum(action['외화거래금액'] ?? '0')}");
        results.add("세금: ${priceNum(action['세금'] ?? '0')}");
        results.add("원화거래금액: ${priceNum(action['원화거래금액'] ?? '0')}");
        results.add("국외수수료: ${priceNum(action['국외수수료'] ?? '0')}");
        results.add("입금통장표시내용: ${action['입금통장표시내용']}");
        results.add("출금통장표시내용: ${action['출금통장표시내용']}");
        results.add("처리점: ${action['처리점']}");
        results.add("입금은행: ${action['입금은행']}");
        results.add("입금계좌번호: ${action['입금계좌번호']}");
      }
    }
    await fetch(logOut(module));
    return results;
  }
}
