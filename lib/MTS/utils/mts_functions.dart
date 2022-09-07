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
}) {
  switch (Job) {
    case '로그인':
      if (idLogin!) {
        return CustomRequest(
            Module: Module,
            Job: Job,
            Input: CustomInput(
              idOrCert: 'ID',
              userId: userId!,
              password: password!,
              certificate: null,
            ));
      } else {
        return CustomRequest(
            Module: Module,
            Job: Job,
            Input: CustomInput(
              idOrCert: 'CERT', // CERT: 인증서, ID: 아이디
              userId: userId!, // IBK, KTB 필수 입력
              password: certPassword!, // IBK, KTB 필수 입력
              certificate: Certificate(
                certName: certUsername!,
                certExpire: certExpire!,
                certPassword: certPassword,
              ),
            ));
      }
    case '증권보유계좌조회':
      return CustomRequest(
        Module: Module,
        Job: Job,
        Input: CustomInput(),
      );
    case '전계좌조회':
      return CustomRequest(
          Module: Module,
          Job: Job,
          Input: CustomInput(
            password: password!, // 키움 증권만 사용 "S": 키움 간편조회, 메리츠 전체계좌, 삼성 계좌잔고
            queryCode: queryCode!, // // 없음: 키움 일반조회, 메리츠 계좌평가, 삼성 종합잔고평가
          )); // "D": 대신,크레온 종합번호+계좌번호, 없음: 일반조회
    case '계좌상세조회':
      return CustomRequest(
          Module: Module,
          Job: Job,
          Input: CustomInput(
            accountNum: accountNum!,
            accountPin: accountPin!, // 입력 안해도 되지만 안하면 구매종목 안나옴.
            queryCode: queryCode!, // 삼성 "K": 외화만, 없음: 기본조회
            showISO: showISO!, // KB "2": 통화코드,현재가,매입평균가 미출력, 없음: 모두출력
          ));
    case '거래내역조회':
      if (!['000', '001', '002', ''].contains(accountExt)) break;
      if (!['01', '02', '05', ''].contains(accountType)) break;
      if (!['1', '2', 'D'].contains(queryCode)) break;
      if (start!.isEmpty) start = sixAgo(start); // 180일 전
      if (end!.isEmpty) end = today(); // 오늘
      return CustomRequest(
          Module: Module,
          Job: Job,
          Input: CustomInput(
            type: accountType!, // "01"위탁 "02"펀드 "05"CMA
            queryCode: queryCode!, // "1"종합거래내역 "2"입출금내역 "D"종합거래내역 간단히
            accountNum: accountNum!,
            accountPin: accountPin!,
            accountExt: accountExt!, // 하나증권만 사용("000"~"002")
            start: start, // YYYYMMDD
            end: end, // YYYYMMDD
          ));
    case '로그아웃':
      return CustomRequest(
        Module: Module,
        Job: Job,
        Input: CustomInput(),
      );
  }
  return null;
}
