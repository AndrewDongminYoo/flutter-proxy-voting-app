// ignore_for_file: non_constant_identifier_names
import '../mts.dart';

CustomRequest? makeFunction(
  CustomModule Module,
  String Job, {
  String Class = '증권서비스',
  bool? idLogin,
  String? userId,
  String? certUsername,
  String? password,
  String? certPassword,
  String? queryCode,
  String? certExpire,
  String? accountNum,
  String? accountPin,
  String? accountExt,
  String? accountType,
  String? showISO,
  String? start,
  String? end,
  String? certPublic,
  String? certPrivate,
}) {
  assert(Class == '증권서비스', '다른 API를 이용하고자 합니까?');
  switch (Job) {
    case '로그인':
      assert(idLogin != null, '아이디 혹은 인증서로 로그인해주세요.');
      if (idLogin!) {
        assert(userId != null, '사용자아이디를 확인해주세요.');
        assert(password != null, '사용자비밀번호를 확인해주세요.');
        return CustomRequest(
            Module: Module,
            Job: Job,
            Input: CustomInput.from({
              '로그인방식': 'ID', // CERT: 인증서, ID: 아이디
              '사용자아이디': userId, // required
              '사용자비밀번호': password, // required
              '인증서': {},
            }));
      } else {
        assert(certExpire != null, '인증서만료일자를 확인해주세요.');
        assert(certExpire != null, '인증서를 확인해주세요.');
        assert(certPassword != null, '인증서비밀번호를 확인해주세요.');
        return CustomRequest(
            Module: Module,
            Job: Job,
            Input: CustomInput.from({
              '로그인방식': 'CERT', // CERT: 인증서, ID: 아이디
              '사용자아이디': userId, // IBK, KTB 필수 입력
              '사용자비밀번호': password, // IBK, KTB 필수 입력
              '인증서': {
                '이름': certUsername,
                '만료일자': certExpire,
                '비밀번호': certPassword,
                '인증서파일': certPublic,
                '개인키파일': certPrivate,
              },
            }));
      }
    case '증권보유계좌조회':
      return CustomRequest(Module: Module, Job: Job, Input: CustomInput());
    case '전계좌조회':
      assert(password != null, '사용자비밀번호를 확인해주세요.');
      assert(queryCode != null, '조회구분코드를 확인해주세요.');
      return CustomRequest(
          Module: Module,
          Job: Job,
          Input: CustomInput.from({
            '사용자비밀번호': password, // 키움 증권만 사용 "S": 키움 간편조회, 메리츠 전체계좌, 삼성 계좌잔고
            '조회구분': queryCode, // // 없음: 키움 일반조회, 메리츠 계좌평가, 삼성 종합잔고평가
          })); // "D": 대신,크레온 종합번호+계좌번호, 없음: 일반조회
    case '계좌상세조회':
      assert(accountPin != null, '계좌비밀번호를 확인해주세요.');
      assert(accountNum != null, '계좌번호를 확인해주세요.');
      assert(queryCode != null, '조회구분코드를 확인해주세요.');
      assert(showISO != null, '통화코드출력여부를 확인해주세요.');
      return CustomRequest(
          Module: Module,
          Job: Job,
          Input: CustomInput.from({
            '계좌번호': accountNum,
            '계좌비밀번호': accountPin, // 입력 안해도 되지만 안하면 구매종목 안나옴.
            '조회구분': queryCode, // 삼성 "K": 외화만, 없음: 기본조회
            '통화코드출력여부': showISO, // KB "2": 통화코드,현재가,매입평균가 미출력, 없음: 모두출력
          }));
    case '거래내역조회':
      assert(accountExt != null, '계좌번호확장을 확인해주세요.');
      assert(accountNum != null, '계좌번호를 확인해주세요.');
      assert(accountPin != null, '계좌비밀번호를 확인해주세요.');
      assert(accountType != null, '상품구분을 확인해주세요.');
      assert(queryCode != null, '조회구분코드를 확인해주세요.');
      if (!['000', '001', '002', ''].contains(accountExt)) break;
      if (!['01', '02', '05', ''].contains(accountType)) break;
      if (!['1', '2', 'D'].contains(queryCode)) break;
      if (start!.isEmpty) start = sixAgo(start); // 180일 전
      if (end!.isEmpty) end = today(); // 오늘
      return CustomRequest(
          Module: Module,
          Job: Job,
          Input: CustomInput.from({
            '상품구분': accountType, // "01"위탁 "02"펀드 "05"CMA
            '조회구분': queryCode, // "1"종합거래내역 "2"입출금내역 "D"종합거래내역 간단히
            '계좌번호': accountNum,
            '계좌비밀번호': accountPin,
            '계좌번호확장': accountExt, // 하나증권만 사용("000"~"002")
            '조회시작일': start, // YYYYMMDD
            '조회종료일': end, // YYYYMMDD
          }));
    case '로그아웃':
      return CustomRequest(Module: Module, Job: Job, Input: CustomInput());
  }
  return null;
}
