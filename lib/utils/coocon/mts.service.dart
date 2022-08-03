// ignore_for_file: avoid_print
// 🐦 Flutter imports:
import 'package:flutter/services.dart';

class CooconMTSService {
  static const platform = MethodChannel('bside.native.dev/info');

  static const cooconSignIn = {
    'Module': 'secShinhan',
    'Class': '증권서비스',
    'Job': '로그인',
    'Input': {
      '로그인방식': 'ID', // CERT: 인증서, ID: 아이디
      '사용자아이디': '', // required // IBK, KTB 필수 입력
      '사용자비밀번호': '', // required // IBK, KTB 필수 입력
      '인증서': {}, // 있을 경우 "이름", "만료일자", "비밀번호" 키로 입력
    },
  };

  static const cooconInput1 = {
    'Module': 'secShinhan',
    'Class': '증권서비스',
    'Job': '증권보유계좌조회',
    'Input': {},
  };

  static const cooconInput2 = {
    'Module': 'secShinhan',
    'Class': '증권서비스',
    'Job': '전계좌조회',
    'Input': {
      '사용자비밀번호': '', // 키움 증권만 사용
      '조회구분': '', // "S": 키움 간편조회, 메리츠 전체계좌, 삼성 계좌잔고
    }, // 없음: 키움 일반조회, 메리츠 계좌평가, 삼성 종합잔고평가
  }; // "D": 대신,크레온 종합번호+계좌번호, 없음: 일반조회

  static const cooconInput3 = {
    'Module': 'secShinhan',
    'Class': '증권서비스',
    'Job': '계좌상세조회', // 상세잔고조회
    'Input': {
      '계좌번호': '',
      '계좌비밀번호': '',
      '조회구분': '', // 삼성 "K": 외화만, 없음: 기본조회
      '통화코드출력여부': '', // KB "2": 통화코드,현재가,매입평균가 미출력, 없음: 모두출력
    },
  };

  static const cooconInput4 = {
    'Module': 'secShinhan',
    'Class': '증권서비스',
    'Job': '전상품조회', // 상세거래내역조회
    'Input': {
      '상품구분': '', // "01"위탁 "02"펀드 "05"CMA
      '조회구분': '', // "1"종합거래내역 "2"입출금내역 "D"종합거래내역 없음:간단히
      '계좌번호': '',
      '계좌비밀번호': '',
      '계좌번호확장': '', // 하나증권만 사용("000"~"002")
      '조회시작일': '', // YYYYMMDD
      '조회종료일': '', // YYYYMMDD
    },
  };

  static const cooconLogout = {
    'Module': 'secShinhan',
    'Class': '증권서비스',
    'Job': '로그아웃',
    'Input': {},
  };

  static void getData() async {
    Future<dynamic> fetchData(dynamic input) async {
      var data = {'data': input};
      var response = await platform.invokeMethod('getMTSData', data);
      print("======${input['Class']} ${input['Job']}======");
      print(response);
      return response;
    }

    try {
      print('mts.service.dart shoot data');
      await fetchData(cooconSignIn);
      await Future.delayed(const Duration(seconds: 2));
      await fetchData(cooconInput2);
      await Future.delayed(const Duration(seconds: 2));
      await fetchData(cooconInput3);
      await Future.delayed(const Duration(seconds: 2));
      await fetchData(cooconLogout);
    } on Exception catch (e, s) {
      print('error alert!: $e');
      print('stack trace!: $s');
    } finally {
      await fetchData(cooconLogout);
    }
  }
}
