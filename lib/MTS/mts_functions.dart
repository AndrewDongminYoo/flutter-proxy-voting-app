// ignore_for_file: non_constant_identifier_names

import 'widgets/formatters.dart';

makeFunction(
  String Module,
  String Job, {
  String Class = '증권서비스',
  bool? idLogin,
  String? username,
  String? password,
  String? queryCode,
  String? certExpire,
  String? accountNum,
  String? accountPin,
  String? accountExt,
  String? accountType,
  String? showISO,
  String? start,
  String? end,
}) {
  assert(Class == '증권서비스');
  switch (Job) {
    case '로그인':
      assert(idLogin != null);
      if (idLogin!) {
        assert(username != null);
        assert(password != null);
        return {
          'Class': Class,
          'Module': Module,
          'Job': Job,
          'Input': {
            '로그인방식': 'ID', // CERT: 인증서, ID: 아이디
            '사용자아이디': username, // required // IBK, KTB 필수 입력
            '사용자비밀번호': password, // required // IBK, KTB 필수 입력
            '인증서': {}, // 있을 경우 "이름", "만료일자", "비밀번호" 키로 입력
          },
        };
      } else {
        assert(certExpire != null);
        return {
          'Class': Class,
          'Module': Module,
          'Job': Job,
          'Input': {
            '로그인방식': 'CERT', // CERT: 인증서, ID: 아이디
            '이름': username,
            '만료일자': certExpire,
            '비밀번호': password,
          },
        };
      }
    case '증권보유계좌조회':
      return {
        'Class': Class,
        'Module': Module,
        'Job': Job,
      };
    case '전계좌조회':
      assert(password != null);
      assert(queryCode != null);
      return {
        'Class': Class,
        'Module': Module,
        'Job': Job,
        'Input': {
          '사용자비밀번호': password, // 키움 증권만 사용
          '조회구분': queryCode, // "S": 키움 간편조회, 메리츠 전체계좌, 삼성 계좌잔고
        }, // 없음: 키움 일반조회, 메리츠 계좌평가, 삼성 종합잔고평가
      }; // "D": 대신,크레온 종합번호+계좌번호, 없음: 일반조회
    case '계좌상세조회':
      assert(accountNum != null);
      assert(accountPin != null);
      assert(queryCode != null);
      assert(showISO != null);
      return {
        'Class': Class,
        'Module': Module,
        'Job': Job, // 상세잔고조회
        'Input': {
          '계좌번호': accountNum,
          '계좌비밀번호': accountPin, // 입력 안해도 되지만 안하면 구매종목 안나옴.
          '조회구분': queryCode, // 삼성 "K": 외화만, 없음: 기본조회
          '통화코드출력여부': showISO, // KB "2": 통화코드,현재가,매입평균가 미출력, 없음: 모두출력
        },
      };
    case '거래내역조회':
      assert(accountExt != null);
      assert(accountNum != null);
      assert(accountPin != null);
      assert(accountType != null);
      assert(queryCode != null);
      if (!['000', '001', '002', ''].contains(accountExt)) return;
      if (!['01', '02', '05', ''].contains(accountType)) return;
      if (!['1', '2', 'D'].contains(queryCode)) return;
      if (start!.isEmpty) start = sixAgo(start);
      if (end!.isEmpty) end = today();
      return {
        'Class': Class,
        'Module': Module,
        'Job': Job, // 상세거래내역조회
        'Input': {
          '상품구분': accountType, // "01"위탁 "02"펀드 "05"CMA
          '조회구분': queryCode, // "1"종합거래내역 "2"입출금내역 "D"종합거래내역 간단히
          '계좌번호': accountNum,
          '계좌비밀번호': accountPin,
          '계좌번호확장': accountExt, // 하나증권만 사용("000"~"002")
          '조회시작일': start, // YYYYMMDD
          '조회종료일': end, // YYYYMMDD
        },
      };
    case '로그아웃':
      return {
        'Class': Class,
        'Module': Module,
        'Job': Job,
      };
  }
}
