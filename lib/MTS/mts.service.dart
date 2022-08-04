// ignore_for_file: avoid_print
// 🐦 Flutter imports:
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CooconMTSService {
  static const platform = MethodChannel('bside.native.dev/info');
  static DateFormat formatter = DateFormat('YYYYMMDD');

  static commonBody(String action) {
    return {
      'Class': '증권서비스',
      'Job': action,
    };
  }

  static makeSignInData(
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

  static accountInquiry(
    String module,
  ) {
    return {
      'Module': module,
      ...commonBody('증권보유계좌조회'),
      'Input': {},
    };
  }

  static accountInquiryAll(
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

  static accountInquiryDetails(
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

  static accountInquiryTransactions(
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
        '계좌비밀번호': password,
        '계좌번호확장': ext, // 하나증권만 사용("000"~"002")
        '조회시작일': start, // YYYYMMDD
        '조회종료일': end, // YYYYMMDD
      },
    };
  }

  static logOut(String module) {
    return {
      'Module': module,
      ...commonBody('로그아웃'),
      'Input': {},
    };
  }

  static Future<dynamic> fetchData(dynamic input) async {
    var data = {'data': input};
    var response = await platform.invokeMethod('getMTSData', data);
    print("======${input['Class']} ${input['Job']}======");
    print(response);
    return response;
  }

  static void getData({
    required String module,
    required String username,
    required String password,
    required String accountNum,
    String start = '',
    String end = '',
    String code = '',
    String unit = '',
    required String passNum,
  }) async {
    try {
      print('mts.service.dart shoot data');
      var input1 = makeSignInData(module, username, password);
      var input2 = accountInquiryAll(module, passNum);
      var input3 = accountInquiryDetails(module, accountNum, passNum,
          code: code, unit: unit);
      await fetchData(input1)
          .whenComplete(() => fetchData(input2))
          .whenComplete(() => fetchData(input3))
          .whenComplete(() => fetchData(logOut(module)));
    } on Exception catch (e, s) {
      print('error alert!: $e');
      print('stack trace!: $s');
    }
  }

  static today() {
    DateTime dateTime = DateTime.now();
    return formatter.format(dateTime);
  }

  static oneMonthAgo(String dDay) {
    final now = DateTime.tryParse(dDay);
    Duration duration = const Duration(days: 30);
    DateTime monthAgo = now!.subtract(duration);
    return formatter.format(monthAgo);
  }
}
